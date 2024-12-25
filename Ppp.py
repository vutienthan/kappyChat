# Определяем логическую функцию
def logical_function(w, x, y, z):
    return ((y <= x) and (z or w)) <= (((x and not w) or (y == z)))

# Печатаем заголовок
print("w x y z F")

# Генерируем таблицу истинности
for w in range(2):
    for x in range(2):
        for y in range(2):
            for z in range(2):
                # Вычисляем значение логической функции
                F = int(logical_function(w, x, y, z))
                # Печатаем строки таблицы истинности
                print(w, x, y, z, F)
