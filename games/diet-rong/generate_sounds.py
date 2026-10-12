#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_sounds.py — Tạo toàn bộ âm thanh cho "Truyền Thuyết Diệt Rồng" bằng code
(tổng hợp sóng âm kiểu máy chơi game 8-bit). Chỉ dùng thư viện có sẵn của Python.

Chạy:
    python generate_sounds.py      # -> assets/sounds/*.wav + assets/sounds/sounds.json
    python build_project.py        # đưa âm thanh vào project GameMaker

Âm thanh được ghép từ vài "nguyên liệu" đơn giản:
    tone()   : một nốt (sóng vuông / tam giác / răng cưa / sin), có thể trượt cao độ
    noise()  : tiếng ồn trắng qua bộ lọc -> tiếng gió, tiếng nổ, tiếng chém
    song()   : ghép nhiều bè (giai điệu, hợp âm rải, bass, trống) theo bản nhạc viết bằng chữ
"""

import array
import json
import math
import os
import random
import wave

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(HERE, "assets", "sounds")
SR = 22050                  # tần số lấy mẫu (đủ cho âm thanh 8-bit, file nhỏ)
SOUNDS = []                 # danh sách đã tạo (để in báo cáo + ghi json)


# =============================================================================
# 1. NGUYÊN LIỆU ÂM THANH
# =============================================================================
def silence(seconds):
    return [0.0] * int(SR * seconds)


def mix(dst, src, at=0.0, gain=1.0):
    """Cộng âm src vào dst, bắt đầu ở giây thứ `at` (dst tự dài ra nếu cần)."""
    i0 = int(at * SR)
    need = i0 + len(src) - len(dst)
    if need > 0:
        dst.extend([0.0] * need)
    for i, v in enumerate(src):
        dst[i0 + i] += v * gain
    return dst


def wave_value(kind, p, duty=0.5):
    """Giá trị của một dạng sóng tại pha p (0..1)."""
    if kind == "square":
        return 1.0 if p < duty else -1.0
    if kind == "tri":
        return 4.0 * abs(p - 0.5) - 1.0
    if kind == "saw":
        return 2.0 * p - 1.0
    return math.sin(2 * math.pi * p)     # "sine"


def tone(freq, dur, kind="square", vol=0.5, duty=0.5, attack=0.004, decay=0.0, release=0.02,
         slide_to=None, vibrato=0.0, vib_rate=6.0):
    """Một nốt nhạc.
    decay   : tốc độ tắt dần (0 = giữ nguyên âm lượng)
    slide_to: trượt cao độ tới tần số này (tiếng 'piu', 'vút')
    vibrato : độ rung cao độ (0.02 = 2%)"""
    n = int(dur * SR)
    out = [0.0] * n
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = freq if slide_to is None else freq * (slide_to / freq) ** (t / dur)
        if vibrato:
            f *= 1 + vibrato * math.sin(2 * math.pi * vib_rate * t)
        phase += f / SR
        env = min(1.0, t / attack) * min(1.0, (dur - t) / release)
        if decay:
            env *= math.exp(-decay * t)
        out[i] = wave_value(kind, phase % 1.0, duty) * env * vol
    return out


def noise(dur, vol=0.5, decay=0.0, cutoff=1.0, cutoff_to=None, attack=0.002, release=0.02, seed=1):
    """Tiếng ồn qua bộ lọc thông thấp: cutoff nhỏ = trầm (ầm ầm), lớn = sáng (xì xì)."""
    rng = random.Random(seed)
    n = int(dur * SR)
    out = [0.0] * n
    y = 0.0
    for i in range(n):
        t = i / SR
        a = cutoff if cutoff_to is None else cutoff + (cutoff_to - cutoff) * (t / dur)
        y += max(0.001, min(1.0, a)) * (rng.uniform(-1, 1) - y)
        env = min(1.0, t / attack) * min(1.0, (dur - t) / release)
        if decay:
            env *= math.exp(-decay * t)
        out[i] = y * env * vol
    return out


def highpass(samples, k=0.9):
    """Lọc thông cao đơn giản (cho tiếng xèo xèo, chũm chọe)."""
    out, prev_x, prev_y = [], 0.0, 0.0
    for x in samples:
        prev_y = k * (prev_y + x - prev_x)
        prev_x = x
        out.append(prev_y)
    return out


def normalize(samples, peak=0.85):
    m = max(1e-9, max(abs(v) for v in samples))
    return [v * peak / m for v in samples]


def save(name, samples, kind="sfx", peak=0.85):
    """Ghi file .wav 16-bit mono."""
    samples = normalize(samples, peak)
    data = array.array("h", (int(max(-1.0, min(1.0, v)) * 32767) for v in samples))
    path = os.path.join(OUT_DIR, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    SOUNDS.append(dict(name=name, file=name + ".wav", kind=kind, duration=round(len(samples) / SR, 6)))


# =============================================================================
# 2. HIỆU ỨNG ÂM THANH (SFX)
# =============================================================================
def make_sfx():
    # ---- vũ khí của người chơi
    s = noise(0.18, 0.9, decay=10, cutoff=0.9, cutoff_to=0.15, attack=0.01)
    mix(s, tone(1800, 0.12, "sine", 0.15, decay=25))
    save("snd_sword", s)                                     # vút + tiếng kim loại

    s = noise(0.28, 0.9, decay=7, cutoff=0.5, cutoff_to=0.06, attack=0.02)
    mix(s, tone(110, 0.2, "sine", 0.5, decay=14, slide_to=60), 0.05)
    save("snd_axe", s)                                       # vù nặng + uỵch

    s = tone(330, 0.3, "tri", 0.8, decay=10, slide_to=260, vibrato=0.03, vib_rate=30)
    mix(s, noise(0.02, 0.6, cutoff=0.9))
    save("snd_bow", s)                                       # tưng (dây cung)

    s = noise(0.03, 0.7, cutoff=0.9)
    mix(s, tone(520, 0.18, "tri", 0.7, decay=16, slide_to=420, vibrato=0.04, vib_rate=40), 0.01)
    save("snd_crossbow", s)                                  # cạch + tưng ngắn

    s = noise(0.4, 0.8, decay=4, cutoff=0.08, cutoff_to=0.3, attack=0.05)
    mix(s, tone(180, 0.35, "saw", 0.15, decay=6, slide_to=90))
    save("snd_fireball", s)                                  # phừng

    s = []
    for k in range(5):
        mix(s, tone(random.Random(k).uniform(900, 1600), 0.05, "square", 0.4, slide_to=300, duty=0.3), k * 0.025)
    save("snd_spark", s, peak=0.5)                                     # xẹt xẹt

    s = noise(0.7, 1.0, decay=5, cutoff=0.25, cutoff_to=0.02, attack=0.003)
    mix(s, tone(70, 0.5, "sine", 0.9, decay=7, slide_to=35))
    save("snd_explosion", s)                                 # bùm

    # ---- trúng đòn, chết
    s = noise(0.07, 0.8, decay=40, cutoff=0.6)
    mix(s, tone(220, 0.08, "square", 0.4, slide_to=90, duty=0.25))
    save("snd_hit", s)

    s = tone(500, 0.25, "square", 0.5, slide_to=90, duty=0.25, decay=4)
    mix(s, noise(0.3, 0.5, decay=10, cutoff=0.3), 0.05)
    save("snd_enemy_die", s)

    s = tone(420, 0.25, "square", 0.6, slide_to=140, duty=0.25, vibrato=0.08, vib_rate=25)
    save("snd_player_hurt", s, peak=0.5)

    s = []
    for k, f in enumerate((392, 330, 262, 196)):
        mix(s, tone(f, 0.22, "square", 0.5, duty=0.25, decay=3), k * 0.18)
    save("snd_player_die", s)

    # ---- di chuyển, kỹ năng
    s = noise(0.22, 0.7, cutoff=0.05, cutoff_to=0.5, attack=0.05, release=0.12)
    save("snd_dash", highpass(s, 0.8))

    s = []
    for k in range(3):
        mix(s, noise(0.2, 0.7, cutoff=0.1, cutoff_to=0.6, attack=0.05, release=0.1, seed=k), k * 0.13)
    mix(s, tone(900, 0.5, "sine", 0.12, vibrato=0.1, vib_rate=8))
    save("snd_spin", s)                                      # lốc xoáy kiếm

    s = []
    for k in range(6):
        mix(s, tone(300 + k * 25, 0.2, "tri", 0.6, decay=12, slide_to=240, vibrato=0.03, vib_rate=30), k * 0.04)
    save("snd_arrow_rain", s)                                # mưa tên

    s = noise(0.08, 0.6, cutoff=0.95)
    for f in (1318, 1568, 1976, 2637):
        mix(s, tone(f, 0.6, "sine", 0.2, decay=4, vibrato=0.01, vib_rate=12), 0.02)
    save("snd_ice", highpass(s, 0.97))                      # vòng băng leng keng

    s = tone(200, 0.15, "square", 0.5, duty=0.5)
    mix(s, tone(150, 0.15, "square", 0.5, duty=0.5), 0.0)
    save("snd_no_mana", s, peak=0.5)                                   # bè bè (không đủ năng lượng)

    # ---- nhặt đồ
    s = tone(988, 0.06, "square", 0.4, duty=0.25)
    mix(s, tone(1319, 0.14, "square", 0.4, duty=0.25, decay=10), 0.06)
    save("snd_coin", s, peak=0.5)                                      # ting ting

    s = []
    for k in range(5):
        mix(s, tone(400 + k * 120, 0.07, "sine", 0.5, decay=20), k * 0.06)
    save("snd_potion", s)                                    # ừng ực

    s = []
    for k, f in enumerate((1568, 2093, 2637)):
        mix(s, tone(f, 0.12, "tri", 0.5, decay=12), k * 0.07)
    save("snd_key", s)                                       # leng keng

    s = []
    for k, f in enumerate((523, 659, 784, 1047, 1319)):
        mix(s, tone(f, 0.12, "square", 0.35, duty=0.25, decay=8), k * 0.07)
    save("snd_heart", s)                                     # tăng máu tối đa

    s = tone(120, 0.3, "saw", 0.35, slide_to=85, vibrato=0.06, vib_rate=14)   # cót két
    for k, f in enumerate((784, 988, 1175, 1568)):
        mix(s, tone(f, 0.15, "square", 0.25, duty=0.25, decay=10), 0.25 + k * 0.06)
    save("snd_chest", s)

    s = noise(0.12, 0.8, decay=25, cutoff=0.2)
    mix(s, tone(90, 0.25, "square", 0.4, decay=12, duty=0.3))
    mix(s, tone(1200, 0.05, "square", 0.2, duty=0.2), 0.12)
    save("snd_door", s)                                      # cạch cửa mở

    # ---- cổng, bẫy
    s = tone(220, 0.9, "sine", 0.6, slide_to=880, vibrato=0.05, vib_rate=9, release=0.3)
    mix(s, tone(440, 0.9, "tri", 0.2, slide_to=1760, release=0.3))
    save("snd_portal", s)

    s = tone(300, 0.3, "square", 0.4, duty=0.25, slide_to=1200, release=0.1)
    save("snd_teleport", s, peak=0.5)

    s = tone(1500, 0.1, "square", 0.3, decay=25, duty=0.3)
    mix(s, tone(2240, 0.1, "square", 0.2, decay=30, duty=0.3))
    save("snd_spikes", s)                                    # xoẹt chông

    # ---- quái
    s = tone(260, 0.2, "tri", 0.7, decay=12, slide_to=200, vibrato=0.04, vib_rate=30)
    save("snd_enemy_shoot", s)

    s = noise(0.5, 1.0, decay=7, cutoff=0.12, cutoff_to=0.02)
    mix(s, tone(60, 0.45, "sine", 1.0, decay=8, slide_to=35))
    save("snd_orc_slam", s)                                  # rầm

    s = tone(110, 1.3, "saw", 0.6, slide_to=65, vibrato=0.12, vib_rate=11, attack=0.08, release=0.4)
    mix(s, tone(55, 1.3, "square", 0.3, slide_to=40, duty=0.3, attack=0.1, release=0.4))
    mix(s, noise(1.3, 0.5, cutoff=0.1, attack=0.1, release=0.5))
    save("snd_dragon_roar", s)                               # rồng gầm

    s = noise(0.6, 0.9, cutoff=0.04, cutoff_to=0.25, attack=0.08, release=0.25)
    mix(s, tone(90, 0.6, "saw", 0.2, vibrato=0.2, vib_rate=18, release=0.25))
    save("snd_dragon_fire", s)                               # rồng phun lửa

    # ---- giao diện
    save("snd_menu_move", tone(660, 0.05, "square", 0.4, duty=0.25), peak=0.5)
    s = tone(660, 0.07, "square", 0.4, duty=0.25)
    mix(s, tone(990, 0.15, "square", 0.4, duty=0.25, decay=8), 0.07)
    save("snd_menu_select", s, peak=0.5)

    # ---- nhạc ngắn
    victory = [("C5", 2), ("C5", 2), ("C5", 2), ("C5", 6), ("G#4", 6), ("A#4", 6), ("C5", 4), ("A#4", 2), ("C5", 12)]
    s = song(150, 3, [voice(victory, "square", 0.3, duty=0.5),
                      voice([("C3", 12), ("G#2", 6), ("A#2", 6), ("C3", 18)], "tri", 0.5),
                      voice([("E4", 12), ("C4", 6), ("D4", 6), ("E4", 18)], "square", 0.12, duty=0.25)])
    save("snd_victory", s, kind="sfx")
    over = [("E5", 4), ("D#5", 4), ("D5", 4), ("C#5", 16)]
    save("snd_gameover", song(90, 2, [voice(over, "tri", 0.6), voice([("A2", 28)], "tri", 0.4)]))


# =============================================================================
# 3. NHẠC NỀN — viết bằng chữ: ("A4", 4) = nốt La quãng 4 dài 4 phách móc kép (1/16)
# =============================================================================
NOTE_INDEX = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}


def note_freq(name):
    """'A4' -> 440 Hz."""
    pitch, octave = name[:-1], int(name[-1])
    midi = 12 * (octave + 1) + NOTE_INDEX[pitch]
    return 440.0 * 2 ** ((midi - 69) / 12)


def parse(text):
    """'E5/4 D5/2 -/2' -> [('E5', 4), ('D5', 2), ('-', 2)]"""
    out = []
    for tok in text.split():
        n, l = tok.split("/")
        out.append((n, int(l)))
    return out


def voice(notes, kind="square", vol=0.3, duty=0.5, decay=0.0, vibrato=0.0, legato=0.9):
    return dict(notes=notes, kind=kind, vol=vol, duty=duty, decay=decay, vibrato=vibrato, legato=legato)


def chord_arp(chords, steps_per_note=2, octave=4):
    """Hợp âm rải: mỗi ô nhịp một hợp âm, các nốt chạy lên xuống."""
    out = []
    for ch in chords:
        tones = CHORDS[ch]
        seq = tones + tones[1:-1][::-1]
        for k in range(16 // steps_per_note):
            n = seq[k % len(seq)]
            out.append((n[:-1] + str(int(n[-1]) + octave - 4), steps_per_note))
    return out


def bass_line(chords, pattern="8th", octave=2):
    out = []
    for ch in chords:
        root = CHORDS[ch][0][:-1]
        if pattern == "8th":
            out += [(root + str(octave), 2), (root + str(octave + 1), 2)] * 4
        elif pattern == "half":
            out += [(root + str(octave), 8)] * 2
        else:  # "quarter"
            out += [(root + str(octave), 4)] * 4
    return out


CHORDS = {
    "C": ["C4", "E4", "G4"], "G": ["G3", "B3", "D4"], "Am": ["A3", "C4", "E4"], "F": ["F3", "A3", "C4"],
    "Dm": ["D4", "F4", "A4"], "E": ["E3", "G#3", "B3"], "A#": ["A#3", "D4", "F4"], "D": ["D4", "F#4", "A4"],
    "Em": ["E4", "G4", "B4"], "B": ["B3", "D#4", "F#4"],
}


def drum_kick():
    return tone(130, 0.14, "sine", 1.0, slide_to=40, decay=18)


def drum_snare(seed):
    s = noise(0.16, 0.7, decay=22, cutoff=0.6, seed=seed)
    return mix(s, tone(190, 0.08, "tri", 0.4, decay=30))


def drum_hat(seed):
    return highpass(noise(0.04, 0.5, decay=60, cutoff=0.95, seed=seed), 0.6)


def song(bpm, bars, voices, drums=None, drum_vol=1.0):
    """Ghép các bè thành một bản nhạc dài đúng `bars` ô nhịp (lặp liền mạch)."""
    step = 60.0 / bpm / 4                     # thời gian 1 móc kép
    total = bars * 16 * step
    out = silence(total)
    for v in voices:
        t = 0.0
        for name, length in v["notes"]:
            dur = length * step
            if name != "-":
                n = tone(note_freq(name), dur * v["legato"], v["kind"], v["vol"], duty=v["duty"],
                         decay=v["decay"], vibrato=v["vibrato"], vib_rate=5.5, release=0.03)
                mix(out, n, t)
            t += dur
    if drums:
        kick, snares, hats = drum_kick(), [drum_snare(k) for k in range(4)], [drum_hat(k) for k in range(4)]
        for bar in range(bars):
            for i, ch in enumerate(drums):
                at = (bar * 16 + i) * step
                if ch == "k":
                    mix(out, kick, at, 0.55 * drum_vol)
                elif ch == "s":
                    mix(out, snares[(bar + i) % 4], at, 0.35 * drum_vol)
                elif ch == "h":
                    mix(out, hats[(bar + i) % 4], at, 0.18 * drum_vol)
    return out[:int(total * SR)]               # cắt đúng độ dài để lặp không bị hụt nhịp


def make_music():
    # ---- Menu: Rê thứ, hùng tráng
    chords = ["Dm", "A#", "C", "Am", "Dm", "A#", "C", "D"]
    lead = parse("D5/6 F5/2 A5/8  A#5/6 A5/2 F5/8  G5/4 E5/4 C5/4 E5/4  A5/12 -/4 "
                 "D6/4 C6/4 A5/4 F5/4  G5/4 A5/4 A#5/8  C6/6 A#5/2 A5/4 G5/4  F#5/8 A5/8")
    save("mus_menu", song(100, 8, [voice(lead, "square", 0.22, duty=0.25, vibrato=0.01),
                                   voice(chord_arp(chords, 2), "tri", 0.12),
                                   voice(bass_line(chords, "half"), "tri", 0.35)],
                          drums="k.......s...k...", drum_vol=0.7), kind="music", peak=0.7)
    # ---- Rừng: Đô trưởng, vui tươi
    chords = ["C", "G", "Am", "F", "C", "G", "F", "G"]
    lead = parse("E5/4 D5/2 E5/2 G5/4 E5/4  D5/4 B4/2 D5/2 G5/8  C5/4 E5/2 A5/2 G5/4 E5/4  F5/4 E5/2 D5/2 C5/8 "
                 "E5/2 G5/2 C6/4 B5/2 A5/2 G5/4  D5/4 G5/4 B5/4 A5/4  A5/4 G5/2 F5/2 E5/4 D5/4  D5/4 E5/2 F5/2 G5/8")
    save("mus_forest", song(128, 8, [voice(lead, "square", 0.2, duty=0.5),
                                     voice(chord_arp(chords, 1), "square", 0.06, duty=0.125),
                                     voice(bass_line(chords, "8th"), "tri", 0.35)],
                            drums="k.h.s.h.k.k.s.h."), kind="music", peak=0.7)
    # ---- Hầm ngục / hang: La thứ, chậm, u ám
    chords = ["Am", "F", "Dm", "E", "Am", "F", "G", "E"]
    lead = parse("A4/6 C5/2 E5/8  F5/6 E5/2 C5/8  D5/4 F5/4 A5/4 G5/4  G#5/8 E5/8 "
                 "-/4 A5/4 G5/2 E5/2 C5/4  D5/4 C5/4 A4/8  B4/4 D5/4 G5/4 F5/4  E5/12 -/4")
    save("mus_dungeon", song(92, 8, [voice(lead, "square", 0.16, duty=0.25, vibrato=0.015),
                                     voice(chord_arp(chords, 2, octave=3), "sine", 0.18),
                                     voice(bass_line(chords, "half", octave=2), "tri", 0.4)],
                             drums="k.......s.......", drum_vol=0.6), kind="music", peak=0.7)
    # ---- Đánh trùm: Mi thứ, nhanh, dồn dập
    chords = ["Em", "C", "D", "B", "Em", "C", "Am", "B"]
    lead = parse("E5/2 E5/2 G5/2 E5/2 B5/4 A5/4  G5/2 G5/2 E5/2 G5/2 C6/4 B5/4  A5/2 A5/2 F#5/2 A5/2 D6/4 C6/4  B5/8 D#5/8 "
                 "E6/4 D6/4 B5/4 G5/4  C6/4 B5/4 G5/4 E5/4  A5/4 C6/4 E6/4 D6/4  B5/4 A5/4 F#5/4 D#5/4")
    save("mus_boss", song(150, 8, [voice(lead, "square", 0.2, duty=0.5),
                                   voice(chord_arp(chords, 1), "square", 0.06, duty=0.25),
                                   voice(bass_line(chords, "8th", octave=2), "saw", 0.22)],
                          drums="k.h.s.h.kkh.s.hh"), kind="music", peak=0.7)


# =============================================================================
# 4. CHƯƠNG TRÌNH CHÍNH
# =============================================================================
def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for f in os.listdir(OUT_DIR):
        if f.endswith(".wav"):
            os.remove(os.path.join(OUT_DIR, f))
    make_sfx()
    make_music()
    with open(os.path.join(OUT_DIR, "sounds.json"), "w", encoding="utf-8") as fp:
        json.dump(SOUNDS, fp, ensure_ascii=False, indent=1)
    total = 0
    print(f"Đã tạo {len(SOUNDS)} âm thanh trong {OUT_DIR}")
    for s in SOUNDS:
        size = os.path.getsize(os.path.join(OUT_DIR, s["file"]))
        total += size
        print(f"  {s['file']:24s} {s['kind']:5s} {s['duration']:6.2f} giây  {size // 1024:5d} KB")
    print(f"Tổng: {total // 1024} KB")


if __name__ == "__main__":
    main()
