#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_audio.py — Tổng hợp nhạc và hiệu ứng âm thanh cho "Tây Sơn" bằng code (docs/07 §5). Chỉ cần numpy + ffmpeg.

Nhạc cụ (mô phỏng, không lấy mẫu thu âm):
    trong()      trống chiến: màng rung (vài họa âm lệch, cao độ tụt nhanh lúc đầu) + tiếng da
    chieng()     chiêng: họa âm không điều hòa, ngân dài, có "ù" nhẹ
    sao()        sáo trúc: sin + họa âm + hơi thổi, rung (vibrato) chậm vào sau, luyến giữa các nốt
    dan_nguyet() đàn nguyệt: dây gảy (Karplus–Strong) có nhấn (bend) kiểu Việt
    ken()        kèn: sóng răng cưa qua bộ lọc formant, rung
    de(), gio()  tiếng dế, gió đêm (nhiễu lọc)

Thang âm: điệu Bắc (do re fa sol la) cho chủ đề; hơi Oán (do mi♭~ fa sol si♭, mi♭ hơi cao, có nhấn) cho nhạc đêm.
Tránh khuôn sáo "nhạc Trung Hoa" (chũm chọe, chạy ngũ cung) theo 07 §5.

Kết quả:
    godot/assets/audio/nhac/{chu_de,dem,thang,thua}.ogg   (nhạc nền lặp liền mạch; thắng/thua không lặp)
    godot/assets/audio/sfx/*.wav

Chạy:  python3 tools/gen_audio.py         (khoảng 1 phút)
"""

import os
import subprocess
import tempfile
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(os.path.dirname(HERE), "godot", "assets", "audio")
SR = 44100
RNG = np.random.default_rng(1789)


# =============================================================================
# Nguyên liệu
# =============================================================================
def t_axis(dur):
    return np.arange(int(dur * SR)) / SR


def env_adsr(n, a=0.005, d=0.1, s=0.6, r=0.1, hold=None):
    """Đường bao ADSR dài n mẫu. hold = thời gian giữ (mặc định: tới lúc nhả)."""
    a_n, d_n, r_n = int(a * SR), int(d * SR), int(r * SR)
    total = n
    hold_n = max(0, total - a_n - d_n - r_n) if hold is None else int(hold * SR)
    e = np.concatenate([
        np.linspace(0, 1, max(a_n, 1), endpoint=False),
        np.linspace(1, s, max(d_n, 1), endpoint=False),
        np.full(hold_n, s),
        np.linspace(s, 0, max(r_n, 1)),
    ])
    if len(e) < n:
        e = np.concatenate([e, np.zeros(n - len(e))])
    return e[:n]


def exp_decay(n, tau):
    return np.exp(-np.arange(n) / (tau * SR))


def spectral_filter(x, fn):
    """Lọc bằng FFT: fn(freqs) -> hệ số khuếch đại."""
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR)
    return np.fft.irfft(X * fn(f), len(x))


def bandpass(lo, hi, soft=1.0):
    def fn(f):
        g = np.ones_like(f)
        g *= 1 / (1 + (lo / np.maximum(f, 1)) ** (2 * soft))
        g *= 1 / (1 + (f / hi) ** (2 * soft))
        return g
    return fn


def noise(dur):
    return RNG.standard_normal(int(dur * SR))


def phase_from_freq(freq):
    """Pha tích lũy từ tần số tức thời (mảng) — để trượt / rung cao độ không bị nứt."""
    return 2 * np.pi * np.cumsum(freq) / SR


def mix_into(dst, src, at):
    i = int(at * SR)
    if i >= len(dst):
        return
    n = min(len(src), len(dst) - i)
    dst[i:i + n] += src[:n]


def reverb_ir(dur=1.8, damp=6000, pre=0.012):
    n = int(dur * SR)
    ir = noise(dur) * exp_decay(n, dur / 6.5)
    ir = spectral_filter(ir, bandpass(120, damp, 0.8))
    ir[: int(pre * SR)] = 0
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    return ir


def convolve(x, ir):
    n = len(x) + len(ir) - 1
    size = 1 << (n - 1).bit_length()
    y = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[:n]
    return y


def reverb(x, wet=0.25, dur=1.8, damp=6000):
    y = convolve(x, reverb_ir(dur, damp))[: len(x)]
    return x * (1 - wet) + y * wet * 0.6


def pan(mono, p):
    """p: -1 trái .. 1 phải (luật công suất bằng nhau)."""
    a = (p + 1) * np.pi / 4
    return np.stack([mono * np.cos(a), mono * np.sin(a)], axis=1)


# =============================================================================
# Nhạc cụ
# =============================================================================
def trong(f0=72.0, dur=1.6, vel=1.0, rim=False):
    """Trống chiến. rim=True: tiếng "cắc" gõ tang trống."""
    n = int(dur * SR)
    t = np.arange(n) / SR
    if rim:
        click = noise(0.06)
        click = spectral_filter(click, bandpass(1800, 6000)) * exp_decay(len(click), 0.012)
        body = np.sin(2 * np.pi * 820 * t[: int(0.08 * SR)]) * exp_decay(int(0.08 * SR), 0.015)
        out = np.zeros(n)
        out[: len(click)] += click * 0.9
        out[: len(body)] += body * 0.5
        return out * vel
    out = np.zeros(n)
    drop = 1 + 0.6 * np.exp(-t / 0.035)            # cao độ tụt nhanh lúc đầu
    for ratio, amp, tau in ((1.0, 1.0, 0.55), (1.59, 0.45, 0.25), (2.14, 0.3, 0.16), (2.3, 0.18, 0.12), (2.65, 0.1, 0.09)):
        out += amp * np.sin(phase_from_freq(f0 * ratio * drop)) * exp_decay(n, tau * (0.6 + 0.4 * vel))
    slap = spectral_filter(noise(0.05), bandpass(300, 3500)) * exp_decay(int(0.05 * SR), 0.01)
    out[: len(slap)] += slap * 0.5
    return np.tanh(out * 1.3 * vel) * 0.8


def chieng(f0=110.0, dur=6.0, vel=1.0):
    n = int(dur * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    partials = ((1.0, 1.0, 3.5), (2.02, 0.5, 2.6), (2.76, 0.35, 1.9), (3.42, 0.25, 1.4), (4.13, 0.18, 1.0),
                (5.4, 0.1, 0.6), (6.8, 0.06, 0.4))
    for ratio, amp, tau in partials:
        bend = 1 + 0.004 * (1 - np.exp(-t / 0.6))  # chiêng "ù" hơi lên giọng khi ngân
        beat = 1 + 0.15 * np.sin(2 * np.pi * (0.7 + ratio * 0.3) * t)
        out += amp * np.sin(phase_from_freq(f0 * ratio * bend)) * exp_decay(n, tau) * beat
    strike = spectral_filter(noise(0.04), bandpass(400, 5000)) * exp_decay(int(0.04 * SR), 0.008)
    out[: len(strike)] += strike * 0.3
    attack = np.minimum(1, t / 0.004)
    return out * attack * 0.5 * vel


def sao(notes, vib=0.012, breath=0.06, vol=0.5):
    """Sáo trúc. notes: [(tần số, thời lượng, luyến_từ_nốt_trước)]. Trả về một câu nhạc liền hơi."""
    freqs = []
    amps = []
    prev = None
    for f, d, legato in notes:
        n = int(d * SR)
        if f is None:                                  # nghỉ (lấy hơi)
            freqs.append(np.full(n, prev or 440.0))
            amps.append(np.zeros(n))
            prev = None
            continue
        tt = np.arange(n) / SR
        if legato and prev:
            glide = np.minimum(1, tt / 0.09)
            fr = prev + (f - prev) * (glide * glide * (3 - 2 * glide))
        else:
            fr = np.full(n, f)
        # rung vào chậm (sau 0.25 s), kiểu luyến láy
        depth = vib * np.clip((tt - 0.25) / 0.4, 0, 1)
        fr = fr * (1 + depth * np.sin(2 * np.pi * 5.2 * tt))
        a = env_adsr(n, a=0.04 if not (legato and prev) else 0.01, d=0.15, s=0.8, r=min(0.12, d * 0.3))
        freqs.append(fr)
        amps.append(a)
        prev = f
    fr = np.concatenate(freqs)
    am = np.concatenate(amps)
    ph = phase_from_freq(fr)
    tone = np.sin(ph) + 0.28 * np.sin(2 * ph) + 0.08 * np.sin(3 * ph) + 0.03 * np.sin(4 * ph)
    air = spectral_filter(noise(len(fr) / SR), bandpass(1500, 7000)) * breath
    return (tone * am + air * am * (0.6 + 0.4 * np.abs(np.sin(ph * 0.5)))) * vol


def dan_nguyet(f, dur=1.4, bend=0.0, bend_at=0.25, vol=0.5, bright=0.5):
    """Đàn nguyệt: dây gảy Karplus–Strong; bend > 0: nhấn lên (tỉ lệ cao độ) sau bend_at giây."""
    n = int(dur * SR)
    out = np.zeros(n)
    # Karplus–Strong theo khối: mỗi khối N mẫu chỉ phụ thuộc khối trước.
    period = SR / f
    N = int(period)
    frac = period - N
    buf = spectral_filter(RNG.uniform(-1, 1, N), bandpass(80, 2000 + 6000 * bright))
    buf /= np.max(np.abs(buf)) + 1e-9
    y = np.zeros(n + N + 1)
    y[:N] = buf
    damp = 0.996
    i = N
    while i < n + N:
        j = min(i + N, n + N)
        k = np.arange(i, j)
        y[k] = damp * ((1 - frac) * 0.5 * (y[k - N] + y[k - N + 1]) + frac * 0.5 * (y[k - N - 1] + y[k - N]))
        i = j
    out = y[N:N + n]
    if bend:
        # nhấn: đọc lại tín hiệu với tốc độ tăng dần → cao độ trượt lên
        t = np.arange(n) / SR
        rate = 1 + bend * np.clip((t - bend_at) / 0.18, 0, 1)
        pos = np.cumsum(rate)
        pos = pos[pos < n - 1]
        out = np.interp(pos, np.arange(n), out)
        out = np.concatenate([out, np.zeros(n - len(out))])
    body = spectral_filter(out, bandpass(150, 4500, 0.7))
    return body * env_adsr(n, a=0.002, d=0.05, s=1.0, r=0.08) * vol


def ken(notes, vol=0.35):
    """Kèn (loa kèn dăm): răng cưa giàu họa âm, lọc formant ~1.1 kHz và ~2.6 kHz, rung nhanh."""
    parts = []
    prev = None
    for f, d, legato in notes:
        n = int(d * SR)
        tt = np.arange(n) / SR
        if f is None:
            parts.append(np.zeros(n))
            prev = None
            continue
        fr = np.full(n, f)
        if legato and prev:
            g = np.minimum(1, tt / 0.06)
            fr = prev + (f - prev) * g
        fr *= 1 + 0.008 * np.sin(2 * np.pi * 6.3 * tt) * np.clip((tt - 0.15) / 0.3, 0, 1)
        ph = phase_from_freq(fr) / (2 * np.pi)
        saw = 2 * (ph % 1.0) - 1
        a = env_adsr(n, a=0.03, d=0.1, s=0.85, r=min(0.1, d * 0.25))
        parts.append(saw * a)
        prev = f
    x = np.concatenate(parts)

    def formant(fq):
        return (1.0 / (1 + ((fq - 1100) / 350) ** 2) + 0.6 / (1 + ((fq - 2600) / 500) ** 2)
                + 0.15 / (1 + (fq / 600) ** 2)) * (fq > 180)
    return np.tanh(spectral_filter(x, formant) * 2.2) * vol


def de(dur, voices=4, vol=0.05):
    """Tiếng dế: chuỗi xung ~4.3–5 kHz, mỗi cụm 3–4 tiếng, lặp lại không đều, nhiều con ở các vị trí."""
    n = int(dur * SR)
    out = np.zeros((n, 2))
    for v in range(voices):
        f = RNG.uniform(4300, 5100)
        p = RNG.uniform(-0.9, 0.9)
        mono = np.zeros(n)
        t0 = RNG.uniform(0, 0.8)
        while t0 < dur:
            pulses = RNG.integers(3, 5)
            for k in range(pulses):
                at = t0 + k * 0.032
                ln = int(0.018 * SR)
                tt = np.arange(ln) / SR
                pulse = np.sin(2 * np.pi * f * tt) * np.sin(np.pi * tt / 0.018) ** 2
                mix_into(mono, pulse, at)
            t0 += RNG.uniform(0.55, 1.4)
        out += pan(mono * RNG.uniform(0.5, 1.0), p)
    return out * vol


def gio(dur, vol=0.12):
    """Gió đêm: nhiễu lọc thấp, cường độ dâng hạ chậm, hơi lệch hai kênh."""
    n = int(dur * SR)
    t = np.arange(n) / SR
    chans = []
    for s in (0, 1):
        x = spectral_filter(noise(dur), bandpass(80, 700, 0.6))
        x /= np.max(np.abs(x)) + 1e-9
        lfo = 0.55 + 0.45 * np.sin(2 * np.pi * (0.07 + 0.02 * s) * t + s) * np.sin(2 * np.pi * 0.023 * t)
        chans.append(x * lfo)
    return np.stack(chans, axis=1) * vol


# =============================================================================
# Thang âm
# =============================================================================
def hz(semis, base=293.66):          # base = D4
    return base * 2 ** (semis / 12)


# Hơi Oán trên D: D, F (hơi cao), G, A, C — mi♭ nhấn được thể hiện bằng F hơi cao + bend
OAN = {"D": 0, "F": 3.3, "G": 5, "A": 7, "C": 10, "d": 12, "f": 15.3, "g": 17, "a": 19, "A,": -5, "C,": -2}
# Điệu Bắc trên D: D E G A B (do re fa sol la dời giọng)
BAC = {"D": 0, "E": 2, "G": 5, "A": 7, "B": 9, "d": 12, "e": 14, "g": 17, "a": 19, "B,": -3, "A,": -5, "G,": -7}


def seq(scale, text, beat, octave=0, base=293.66):
    """'D:2 F:1 ~G:1 -:1' → [(Hz, giây, luyến)]; '~' = luyến từ nốt trước, '-' = nghỉ."""
    out = []
    for tok in text.split():
        name, ln = tok.split(":")
        legato = name.startswith("~")
        name = name.lstrip("~")
        if name == "-":
            out.append((None, float(ln) * beat, False))
        else:
            out.append((hz(scale[name] + 12 * octave, base), float(ln) * beat, legato))
    return out


def seq_len(notes):
    return sum(d for _, d, _ in notes)


# =============================================================================
# Ghép bản nhạc
# =============================================================================
def loopable(stereo, loop_len, xfade=3.0):
    """Cắt còn loop_len giây, phần đuôi dư được trộn chéo vào đầu để lặp không vấp."""
    n = int(loop_len * SR)
    xf = int(xfade * SR)
    out = stereo[:n].copy()
    tail = stereo[n:n + xf]
    if len(tail) == xf:
        ramp = np.linspace(1, 0, xf)[:, None]
        out[:xf] = out[:xf] * (1 - ramp) + tail * ramp
    return out


def master(stereo, target_rms_db=-18.0, peak_db=-1.0):
    rms = np.sqrt(np.mean(stereo ** 2)) + 1e-12
    g = 10 ** (target_rms_db / 20) / rms
    x = stereo * g
    peak = np.max(np.abs(x))
    lim = 10 ** (peak_db / 20)
    if peak > lim:
        x = np.tanh(x / lim * 0.9) * lim / np.tanh(0.9)
    return x


def song_dem():
    """Đêm (màn 4): thưa, căng. Dế + gió, trống xa, chiêng trầm, sáo hơi Oán, đàn nguyệt thưa. Vòng lặp 64 s."""
    L = 64.0
    total = L + 4.0
    mix = np.zeros((int(total * SR), 2))
    mix += de(total, voices=5, vol=0.035)
    mix += gio(total, vol=0.09)
    # trống xa: "tùng … tùng" mỗi 8 s, thêm vang dài
    drums = np.zeros(int(total * SR))
    for k in range(int(total // 8)):
        at = 2.0 + k * 8.0
        mix_into(drums, trong(72, 2.0, 0.55), at)
        if k % 2 == 1:
            mix_into(drums, trong(72, 2.0, 0.4), at + 0.75)
    drums = spectral_filter(drums, bandpass(30, 900))         # xa: mất tiếng cao
    drums = reverb(drums, wet=0.55, dur=2.6, damp=1800)
    mix += pan(drums, -0.25) * 0.55
    # chiêng trầm mỗi 32 s
    gong = np.zeros(int(total * SR))
    for at in (0.0, 32.0):
        mix_into(gong, chieng(73, 9.0, 0.7), at)
    mix += pan(reverb(gong, 0.4, 2.4, 3000), 0.2) * 0.3
    # sáo: hai câu, hơi Oán, nhiều luyến
    beat = 0.62
    p1 = seq(OAN, "A:2 ~C:1 ~A:1 G:1.5 ~F:0.5 ~G:2 -:1 D:1 F:1 ~G:2 ~A:3", beat)
    p2 = seq(OAN, "d:2 ~C:1 ~A:1 ~G:2 F:1 ~D:1.5 ~C,:0.5 ~D:4", beat)
    flute = np.zeros(int(total * SR))
    mix_into(flute, sao(p1, vol=0.42), 6.0)
    mix_into(flute, sao(p2, vol=0.42), 6.0 + seq_len(p1) + 3.0)
    mix_into(flute, sao(seq(OAN, "G:2 ~A:1 ~C:1 ~A:3 -:1 G:1 ~F:1 ~D:4", beat), vol=0.38), 40.0)
    mix += pan(reverb(flute, 0.38, 2.2, 7000), 0.15)
    # đàn nguyệt: vài tiếng gảy thưa, có nhấn
    lute = np.zeros(int(total * SR))
    plucks = [(4.0, "D", 0), (5.2, "A,", 0), (20.0, "F", 0.06), (21.0, "D", 0), (28.5, "G", 0),
              (36.0, "A,", 0), (37.0, "D", 0.05), (52.0, "C", 0), (53.1, "A", 0.0), (54.2, "G", 0.06)]
    for at, name, bend in plucks:
        mix_into(lute, dan_nguyet(hz(OAN[name] - 12), 2.0, bend=bend, vol=0.5), at)
    mix += pan(reverb(lute, 0.3), -0.35) * 0.7
    return master(loopable(mix, L), -20.0)


def song_chu_de():
    """Chủ đề (menu): hào hùng, chậm. Trống chiến, chiêng, kèn điệu Bắc, đàn nguyệt rải. Vòng lặp 8 ô nhịp × 4 phách."""
    bpm = 76
    beat = 60 / bpm
    bars = 16
    L = bars * 4 * beat
    total = L + 4.0
    mix = np.zeros((int(total * SR), 2))
    # trống: tùng (1) … tùng (2.5) cắc (3) tùng (4); ô cuối mỗi câu dồn
    drums = np.zeros(int(total * SR))
    for b in range(bars):
        t0 = b * 4 * beat
        fill = b % 4 == 3
        hits = [(0, 1.0, False), (1.5, 0.7, False), (2, 0.5, True), (3, 0.8, False)]
        if fill:
            hits = [(0, 1.0, False), (1, 0.7, False), (2, 0.8, False), (2.5, 0.6, False), (3, 0.9, False), (3.5, 0.9, False)]
        for pos, v, rim in hits:
            mix_into(drums, trong(92, 1.4, v, rim=rim), t0 + pos * beat)
    # loa điện thoại gần như không phát dưới 150 Hz: trống để cao hơn và nhỏ hơn cho giai điệu nổi
    mix += pan(reverb(drums, 0.3, 1.6, 5000), 0.0) * 0.45
    gong = np.zeros(int(total * SR))
    for b in range(0, bars, 4):
        mix_into(gong, chieng(98, 7.0, 0.8), b * 4 * beat)
    mix += pan(reverb(gong, 0.35), 0.25) * 0.32
    # kèn: giai điệu điệu Bắc 2 câu (8 ô nhịp), bắt đầu từ ô 4 (sau phần trống dạo)
    melody = ("A:2 ~B:1 ~A:1 G:2 E:2 D:3 ~E:1 G:4 "
              "A:2 d:2 ~B:1 ~A:1 G:2 A:4 -:4 "
              "d:2 ~e:1 ~d:1 B:2 A:2 G:3 ~A:1 E:4 "
              "D:2 E:2 G:1 ~A:1 ~G:2 D:4 -:4")
    horn = ken(seq(BAC, melody, beat, octave=0, base=293.66), vol=0.4)
    h = np.zeros(int(total * SR))
    mix_into(h, horn, 4 * 4 * beat)
    mix += pan(reverb(h, 0.3, 2.0, 6500), -0.1)
    # đàn nguyệt rải hợp âm ngũ cung dưới giai điệu
    lute = np.zeros(int(total * SR))
    pattern = ["D", "A", "d", "A", "G", "d", "B", "A"]
    for b in range(bars):
        for k, name in enumerate(pattern):
            at = b * 4 * beat + k * beat / 2
            mix_into(lute, dan_nguyet(hz(BAC[name] - 12), 0.9, vol=0.22, bright=0.35), at)
    mix += pan(reverb(lute, 0.25), 0.4) * 0.6
    return master(loopable(mix, L, 2.5), -17.0)


def stinger_thang():
    dur = 5.0
    mix = np.zeros((int(dur * SR), 2))
    drums = np.zeros(int(dur * SR))
    for k in range(8):
        mix_into(drums, trong(72, 1.2, 0.5 + k * 0.06), k * 0.09)
    mix_into(drums, trong(66, 2.0, 1.0), 0.8)
    mix += pan(reverb(drums, 0.3), 0) * 0.8
    mix_into(mix, pan(reverb(chieng(98, 4.2, 1.0), 0.35), 0.2) * 0.45, 0)
    horn = ken(seq(BAC, "D:0.5 G:0.5 A:1 ~d:2.5", 0.3), vol=0.35)
    h = np.zeros(int(dur * SR))
    mix_into(h, horn, 0.8)
    mix += pan(reverb(h, 0.3), -0.1)
    fade = np.ones(len(mix))
    fade[-int(0.8 * SR):] = np.linspace(1, 0, int(0.8 * SR))
    return master(mix * fade[:, None], -16.0)


def stinger_thua():
    dur = 5.5
    mix = np.zeros((int(dur * SR), 2))
    mix_into(mix, pan(reverb(chieng(65, 5.5, 0.8), 0.45, 2.6, 2500), 0) * 0.5, 0)
    fl = sao(seq(OAN, "A:1.5 ~G:1 ~F:1 ~D:3", 0.45), vol=0.4)
    f = np.zeros(int(dur * SR))
    mix_into(f, fl, 0.5)
    mix += pan(reverb(f, 0.45, 2.4), 0.1)
    fade = np.ones(len(mix))
    fade[-int(1.0 * SR):] = np.linspace(1, 0, int(1.0 * SR))
    return master(mix * fade[:, None], -19.0)


# =============================================================================
# Hiệu ứng
# =============================================================================
def add(*xs):
    """Cộng các tín hiệu dài ngắn khác nhau (đệm 0 cho bằng nhau)."""
    n = max(len(x) for x in xs)
    out = np.zeros(n)
    for x in xs:
        out[: len(x)] += x
    return out


def norm(x, peak=0.89):
    return x / (np.max(np.abs(x)) + 1e-9) * peak


def fade_out(x, sec=0.03):
    n = min(len(x), int(sec * SR))
    x = x.copy()
    x[-n:] *= np.linspace(1, 0, n)
    return x


def sfx_all():
    s = {}
    # giao diện: chạm nhẹ (gõ gỗ), chọn quân (gõ gỗ + tiếng sáo ngắn), lật trang
    def go_go(f=1250, dur=0.09):
        t = t_axis(dur)
        return (np.sin(2 * np.pi * f * t) + 0.4 * np.sin(2 * np.pi * f * 2.7 * t)) * exp_decay(len(t), 0.018)
    s["cham"] = norm(go_go(), 0.6)
    s["chon"] = norm(add(go_go(1050), np.pad(go_go(1400, 0.12), (int(0.05 * SR), 0)) * 0.8), 0.6)
    page = spectral_filter(noise(0.25), bandpass(1500, 8000)) * env_adsr(int(0.25 * SR), 0.03, 0.05, 0.5, 0.15)
    s["lat_trang"] = norm(page, 0.4)
    # bước chân (bộ binh): hai bước lạo xạo
    step = spectral_filter(noise(0.07), bandpass(200, 2500)) * exp_decay(int(0.07 * SR), 0.018)
    steps = np.zeros(int(0.32 * SR))
    mix_into(steps, step, 0)
    mix_into(steps, step * 0.8, 0.16)
    s["di"] = norm(steps, 0.45)
    # voi: bước nặng + rống ngắn
    thud = trong(45, 0.5, 1.0) + spectral_filter(noise(0.5), bandpass(40, 300)) * exp_decay(int(0.5 * SR), 0.06) * 0.6
    s["voi_buoc"] = norm(thud, 0.75)
    tt = t_axis(1.1)
    fr = 300 + 260 * np.sin(np.pi * np.clip(tt / 1.1, 0, 1)) ** 0.7
    ph = phase_from_freq(fr) / (2 * np.pi)
    roar = (2 * (ph % 1) - 1)
    roar = spectral_filter(roar, lambda f: 1 / (1 + ((f - 900) / 500) ** 2) + 0.5 / (1 + ((f - 2200) / 700) ** 2))
    roar += spectral_filter(noise(1.1), bandpass(600, 3000)) * 0.25
    s["voi_rong"] = norm(np.tanh(roar * 3) * env_adsr(len(tt), 0.08, 0.2, 0.8, 0.35), 0.7)
    # đánh cận chiến: vút + chát gỗ/sắt
    whoosh = spectral_filter(noise(0.16), bandpass(600, 4000)) * np.sin(np.pi * t_axis(0.16) / 0.16) ** 2
    t2 = t_axis(0.2)
    clang = (np.sin(2 * np.pi * 1900 * t2) + 0.6 * np.sin(2 * np.pi * 2730 * t2) + 0.4 * np.sin(2 * np.pi * 4100 * t2)) * exp_decay(len(t2), 0.05)
    melee = np.zeros(int(0.38 * SR))
    mix_into(melee, whoosh * 0.6, 0)
    mix_into(melee, clang * 0.5, 0.12)
    mix_into(melee, spectral_filter(noise(0.05), bandpass(300, 3000)) * exp_decay(int(0.05 * SR), 0.01), 0.12)
    s["danh"] = norm(melee, 0.75)
    # hỏa mai: nổ khô + vang
    blast = noise(0.6) * exp_decay(int(0.6 * SR), 0.05)
    blast = spectral_filter(blast, bandpass(60, 5000, 0.7))
    crack = spectral_filter(noise(0.02), bandpass(2000, 9000)) * 2
    blast[: len(crack)] += crack
    s["sung"] = norm(reverb(np.tanh(blast * 2), 0.3, 1.2, 3000), 0.85)
    # hỏa hổ: phụt lửa (nhiễu lọc dâng rồi tắt) + lách tách
    fire = spectral_filter(noise(0.9), bandpass(150, 2500)) * env_adsr(int(0.9 * SR), 0.05, 0.2, 0.7, 0.5)
    for k in range(10):
        mix_into(fire, spectral_filter(noise(0.01), bandpass(2000, 8000)) * RNG.uniform(0.5, 1.2), RNG.uniform(0.1, 0.85))
    s["lua"] = norm(fire, 0.75)
    # bị đánh: thịch
    s["trung"] = norm(add(trong(110, 0.25, 0.7), spectral_filter(noise(0.08), bandpass(200, 1500)) * exp_decay(int(0.08 * SR), 0.02)), 0.6)
    # quân bị hạ: thịch trầm rơi xuống
    t3 = t_axis(0.6)
    fall = np.sin(phase_from_freq(140 * np.exp(-t3 / 0.25))) * exp_decay(len(t3), 0.18)
    fall += spectral_filter(noise(0.6), bandpass(80, 900)) * exp_decay(len(t3), 0.1) * 0.6
    s["ha"] = norm(fall, 0.7)
    # lên cấp: đàn nguyệt rải lên + chiêng nhỏ
    up = np.zeros(int(1.4 * SR))
    for k, name in enumerate(["D", "E", "G", "A", "d"]):
        mix_into(up, dan_nguyet(hz(BAC[name]), 0.8, vol=0.5), k * 0.08)
    mix_into(up, chieng(392, 1.2, 0.5), 0.4)
    s["len_cap"] = norm(reverb(up, 0.25), 0.7)
    # chiếm đồn/làng: hai tiếng trống + kèn ngắn
    cap = np.zeros(int(1.3 * SR))
    mix_into(cap, trong(80, 1.0, 0.8), 0)
    mix_into(cap, trong(80, 1.0, 0.9), 0.22)
    mix_into(cap, ken(seq(BAC, "G:0.4 ~A:0.9", 0.5), 0.4), 0.3)
    s["chiem"] = norm(reverb(cap, 0.25), 0.75)
    # mua lính: trống một tiếng + gõ gỗ
    rec = np.zeros(int(0.9 * SR))
    mix_into(rec, trong(90, 0.8, 0.7), 0)
    mix_into(rec, go_go(900, 0.1), 0.16)
    s["mua"] = norm(rec, 0.65)
    # vàng: tiếng tiền đồng leng keng
    coins = np.zeros(int(0.6 * SR))
    for k in range(4):
        tc = t_axis(0.3)
        f = RNG.uniform(2800, 4200)
        mix_into(coins, (np.sin(2 * np.pi * f * tc) + 0.5 * np.sin(2 * np.pi * f * 1.48 * tc)) * exp_decay(len(tc), 0.06), k * 0.06 + RNG.uniform(0, 0.02))
    s["vang"] = norm(coins, 0.45)
    # trống báo động: dồn dập, gấp
    alarm = np.zeros(int(2.2 * SR))
    for k in range(14):
        mix_into(alarm, trong(85, 0.6, 0.6 + 0.4 * (k % 2)), k * 0.13)
    s["trong_bao_dong"] = norm(reverb(alarm, 0.35, 1.6, 4000), 0.85)
    # báo động (lính hô): tù và — sóng tam giác trượt lên, thô
    t4 = t_axis(1.2)
    fr = 220 * (1 + 0.12 * np.clip(t4 / 0.25, 0, 1)) * (1 + 0.01 * np.sin(2 * np.pi * 5 * t4))
    ph = phase_from_freq(fr) / (2 * np.pi)
    horn = 2 * np.abs(2 * (ph % 1) - 1) - 1 + 0.4 * (2 * (ph % 1) - 1)
    horn = spectral_filter(horn, bandpass(150, 2200))
    s["bao_dong"] = norm(reverb(np.tanh(horn * 2) * env_adsr(len(t4), 0.08, 0.1, 0.9, 0.4), 0.4, 2.0, 3000), 0.7)
    # phục kích / lộ diện: hai nốt gảy căng
    amb = np.zeros(int(1.0 * SR))
    mix_into(amb, dan_nguyet(hz(OAN["F"]), 0.9, bend=0.06, vol=0.6), 0)
    mix_into(amb, trong(60, 0.8, 0.8), 0.02)
    s["phuc_kich"] = norm(amb, 0.75)
    lo = dan_nguyet(hz(OAN["A"]), 0.6, bend=0.05, vol=0.6)
    s["lo_dien"] = norm(lo, 0.55)
    return {k: fade_out(v) for k, v in s.items()}


# =============================================================================
# Ghi file
# =============================================================================
def write_wav(path, x, channels=1):
    x = np.clip(x, -1, 1)
    data = (x * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(channels)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def write_ogg(path, stereo, quality=4):
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        tmp_path = tmp.name
    try:
        write_wav(tmp_path, stereo.reshape(-1), channels=2)
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp_path, "-c:a", "libvorbis", "-q:a", str(quality), path],
                       check=True)
    finally:
        os.remove(tmp_path)


def main():
    os.makedirs(os.path.join(ROOT, "nhac"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "sfx"), exist_ok=True)
    for name, fn in (("dem", song_dem), ("chu_de", song_chu_de), ("thang", stinger_thang), ("thua", stinger_thua)):
        x = fn()
        write_ogg(os.path.join(ROOT, "nhac", name + ".ogg"), x)
        print("nhạc %-8s %5.1f s  RMS %5.1f dB  đỉnh %5.1f dB" % (name, len(x) / SR, 20 * np.log10(np.sqrt(np.mean(x ** 2))),
                                                               20 * np.log10(np.max(np.abs(x)))))
    for name, x in sfx_all().items():
        write_wav(os.path.join(ROOT, "sfx", name + ".wav"), x)
        print("sfx  %-15s %4.2f s" % (name, len(x) / SR))


if __name__ == "__main__":
    main()
