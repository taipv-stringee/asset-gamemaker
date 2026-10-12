/// Hỏa Long - trùm cuối. Là con của obj_enemy nên trúng đòn giống quái thường,
/// nhưng có máy trạng thái riêng: bay lượn -> phun lửa / vòng cầu lửa / gọi dơi.
event_inherited();
hp = 160;
hp_max = hp;
heavy = true;
flying = true;
can_flip = false;
contact_dmg = 2;
coin_drop = 0;
potion_chance = 0;
name = "Hỏa Long";
awake = false;     // thức dậy khi người chơi lại gần
mode = 0;          // 0 bay lượn, 1 phun lửa, 2 vòng cầu lửa, 3 gọi dơi
timer = 120;
t = 0;
shots = 0;
