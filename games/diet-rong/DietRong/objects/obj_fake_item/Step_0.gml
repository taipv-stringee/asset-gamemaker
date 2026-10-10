y -= 0.6;
image_xscale += 0.012;
image_yscale += 0.012;
image_alpha -= 0.01;
if (image_alpha <= 0) instance_destroy();
