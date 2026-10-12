y += vy;
vy *= 0.94;
life--;
if (life <= 0) instance_destroy();
