print("w x y z F")
# Проходим по всем комбинациям значений переменных
for w in range(2):
    for x in range(2):
        for y in range(2):
            for z in range(2):
                # Логическое выражение
                F = ((y <= x) and (z or w)) <= ((x and not w) or (y == z))
                # Вывод комбинаций переменных и значения функции
                print(w, x, y, z, int(F))
