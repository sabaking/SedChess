#n
1s/.*/\
    @\
    figures()\
    label(loop)\
        board()\
        input()\
        move-white()\
        select-figures(I)\
        label(bishop)\
            iter-bishop()\
            break-if-end(bishop)\
            set-array()\
            estimate-white-pieces()\
            set-array()\
            estimate-black-pieces()\
            estimate-black-bishop()\
            l()\
            sum-array()\
            sub-array()\
            delete-last-board()\
            store-iter()\
        back(bishop)\
        select-figures(N)\
        label(knight)\
            iter-knight()\
            break-if-end(knight)\
            set-array()\
            estimate-white-pieces()\
            set-array()\
            estimate-black-pieces()\
            estimate-black-knight()\
            sum-array()\
            sub-array()\
            delete-last-board()\
            store-iter()\
        back(knight)\
        select-figures(K)\
        label(king)\
            iter-king()\
            break-if-end(king)\
            set-array()\
            estimate-white-pieces()\
            set-array()\
            estimate-black-pieces()\
            estimate-black-king()\
            sum-array()\
            sub-array()\
            delete-last-board()\
            store-iter()\
        back(king)\
        select-figures(R)\
        label(rook)\
            iter-rook()\
            break-if-end(rook)\
            set-array()\
            estimate-white-pieces()\
            estimate-black-pieces()\
            sub-array()\
            delete-last-board()\
            store-iter()\
        back(rook)\
        find-best-move()\
        move-black()\
        board()\
    back(loop)\
/

# estimate-black-pieces()\
# estimate-black-queen()\
# estimate-black-knight()\
# estimate-black-pawn()\
# estimate-black-king()\
# estimate-black-bishop()\
# estimate-black-queen()\


# оценки запрограммированы по матрицам из книги
# «Программирование шахмат и других логических игр» Корнилова Евгения Николаевича

# переформатирование команд
1s/ *//g; 1s/\n\n*/ /g; 1s/^ //

# обработка поступающей команды
1!{
    /^[a-h][1-8] *[a-h][1-8]$/ {
        # добавляем полученные значения впереди стека исполнения
        G; s/\n/ /
        # переходим на исполнение команд
        b @
    }

    # игрок хочет выйти
    /^q/ q

    # введена какая-то ерунда, стираем и возвращаем стек команд
    i\
    [12H[J[1A
    s/.*//

    g
    b
}

:@
s/@\([^ ]* \)/\1@/

# начать массив
/@set-array()/ {
    s/^/ARRAY /
    b @
}

# метка
/@label(/ {
    b @
}

# переход к метке
/@back(/ {
    s/label(\([^)]*\))\(.*\)@back(\1)/@label(\1)\2back(\1)/
    b @
}

# выход из цикла, если на вершине END
/@break-if-end(/ {
    /^END */{
        s///
        s/@break-if-end(\([^)]*\))\(.*\)back(\1)/break-if-end(\1)\2@back(\1)/
    }
    b @
}

# ввод данных
/@input()/ {
    h; b
}

# удаление последней доски
/@delete-last-board()/ {
    s/\(.*\)Board:[^ ]* */\1/
    b @
}

# дублирование доски
/@copy-board()/ {
    s/\(Board:[^ ]*\)/\1 \1/
    b @
}

# генерация начального состояния доски
/@figures()/ {
    # формат: XYFig
    # координаты белых тут и дальше должны идти НИЖЕ чёрных
    # БОЛЬШИЕ — чёрные, маленькие — белые
    s/^/Board:\
a8Rb8Nc8Id8Qe8Kf8Ig8Nh8R\
a7Pb7Pc7Pd7Pe7Pf7Pg7Ph7P\
a6 b6 c6 d6 e6 f6 g6 h6 \
a5 b5 c5 d5 e5 f5 g5 h5 \
a4 b4 c4 d4 e4 f4 g4 h4 \
a3 b3 c3 d3 e3 f3 g3 h3 \
a2pb2pc2pd2pe2pf2pg2ph2p\
a1rb1nc1id1qe1kf1ig1nh1r /
# пробел в конце нужен!

    s/\n//g

    b @
}

# вывод доски
/@board()/ {
    # сохраняем стек команд
    h
    # убираем всё, кроме доски (берём всегда последнюю доску)
    s/.*Board://
    s/ .*$//
    # расшифровываем доску
    # Pawn, Queen, King, bIshop, kNight, Rook
    y/pqkinrPQKINR12345678abcd/♟♛♚♝♞♜♙♕♔♗♘♖987654323579/
    s/\([1-9e-h]\)\([1-9]\)\(.\)/[\2;\1H\3 /g

    # расцвечиваем
    s/[8642];[37eg]H/&[48;5;209;37;1m/g
    s/[9753];[37eg]H/&[48;5;94;37;1m/g
    s/[8642];[59fh]H/&[48;5;94;37;1m/g
    s/[9753];[59fh]H/&[48;5;209;37;1m/g

    # двузначные числа
    s/e/11/g;s/f/13/g;s/g/15/g;s/h/17/g

    s/$/[0m[11H/
    # выводим доску и возвращаем всё как было
    i\
[2J[1;3Ha b c d e f g h\
8\
7\
6\
5\
4\
3\
2\
1\
\
Enter command:
    p
    g

    b @
}

# делаем ход по введённым пользователем данным
/@move-white()/ {
    # гарды основных регулярок (их нужно тщательно защищать от несрабатываний,
    # иначе sed выдаст ошибку и остановится)
    # вычищаем всё, кроме доски и первых двух значений
    h; s/\([^ ]*\) \([^ ]*\).*Board:\([^ ]*\).*/\1 \2 \3/
    
    # выделяем указанные клетки
    s/\([^ ]*\) [^ ]* .*\(\1.\)/&(1:\2)/
    s/[^ ]* \([^ ]*\) .*\(\1.\)/&(2:\2)/
    # теперь они имеют формат:
    # номер_по_порядку_ввода:XYФигура
    s/.*(\(.....\)).*(\(.....\)).*/\1 \2/

    # теперь надо проверить:
    # 1. что берём не чужую и не пустую фигуру
    /1:..[PQKINR ]/ {
        g; s/[^ ]* [^ ]* *//; b @
    }

    # 2. не кладём на место своей фигуры
    /2:..[pqkinr]/ {
        g; s/[^ ]* [^ ]* *//; b @
    }

    # порядок такой:
    # указанные координаты у найденных фигур меняем между собой

    # если ход будет вперёд…
    /2:.*1:/ {
        g
        #    1        2                3            4           5
        /\([^ ]*\) \([^ ]*\) \(.*Board:[^ ]*\)\2.\([^ ]*\)\1\([pqkinr]\)/ {
            s//\3\1 \4\2\5/
            b @
        }
    }

    # ход назад
    g
    #     1         2            3                4          5
    s/\([^ ]*\) \([^ ]*\) \(.*Board:[^ ]*\)\1\([pqkinr]\)\([^ ]*\)\2./\3\2\4\5\1 /
    b @
}

# количество оставшихся фигур
/@count-pieces()/ {
    h
    # убираем всё, кроме доски
    s/.*Board://
    s/ .*$//
    # убираем всё, кроме белых фигур
    s/[^pqkinrPQKINR]//g
    # считаем
    s/./1/g
    # возвращаем стек команд
    G
    # после G появился перевод строки, убираем его
    s/\n/ /

    b @
}

#оценочная функция имеющихся чёрных фигур
/@estimate-black-pieces()/ {
    # пешка — 100, слон и конь — 300, ладья — 500, ферзь — 900, король — 9000,
    # ещё 9000 — псевдофигура чёрных, чтобы не было переполнения = 21900

    # очистка всего лишнего
    h; s/.*Board://; s/ .*$//

    # убираем всё, кроме подсчитываемых фигур
    s/[^PINRQK]//g

    # считаем количество * коэффициент фигуры (ферзь Q — единственный)
    s/P/1/g; s/[NI]/111/g; s/R/11111/g; s/Q/111111111/
    # король, ставим вперёд к псевдофигуре
    s/^\(.*\)K/HHHHHHHHH\1/
    # чёрная псевдофигура
    s/^/HHHHHHHHH/

    # группируем сотни и тысячи
    s/1111111111/H/g; s/HHHHHHHHHH/T/g

    # вставляем двоеточия
    s/\(.\)\1*/&:/g
    # если нет единиц, в конец — ещё одно двоеточие
    /1/ ! s/$/:/
    # если нет сотен, то до единиц или последнего двоеточия — ещё двоеточие
    /H/ ! s/[1:]/:&/

    y/HT/11/; s/$/:B/
    # добавляем к сохранённому стеку
    G; s/\n/ /

    b @
}

#оценочная функция имеющихся белых фигур
/@estimate-white-pieces()/ {
    # пешка — 100, слон и конь — 300, ладья — 500, ферзь — 900, король — 9000

    # очистка всего лишнего
    h; s/.*Board://; s/ .*$//
    # убираем всё, кроме подсчитываемых фигур
    s/[^pinrqk]//g
    # считаем количество * коэффициент фигуры (ферзь q — единственный)
    s/p/1/g; s/[ni]/111/g; s/r/11111/g; s/q/111111111/

    # король, ставим вперёд
    s/^\(.*\)k/HHHHHHHHH\1/

    # группируем сотни и тысячи
    s/1111111111/H/g; s/HHHHHHHHHH/T/g

    # вставляем двоеточия
    s/\(.\)\1*/&:/g
    # если нет единиц, в конец — ещё одно двоеточие
    /1/ ! s/$/:/
    # если нет сотен, то до единиц или последнего двоеточия — ещё двоеточие
    /H/ ! s/[1:]/:&/

    y/HT/11/; s/$/:B/
    # добавляем к сохранённому стеку
    G; s/\n/ /

    b @
}

#для отладки: вывод текущего стека
/@log()/ {
    l
    q
}

/@l()/ {
    h
    l
    w chess.log
    g
}

#оценочная функция для позиции чёрных пешек
/@estimate-black-pawn()/ {
    # очистка всего лишнего
    h; s/.*Board://; s/ .*$//
    # оставляем только чёрные и белые пешки, перекодируем их в понятные координаты
    # теперь пешки записаны вот так: XЦвет (где Цвет — Black или White), разделены пробелом
    s/[a-h][1-8][^Pp]//g; y/Ppabcdefgh/BW12345678/; s/\([1-8]\)[1-8]/ \1/g

    # → Этап 1
    # ищем чёрные пешки, на вертикали у которых стоят белые, координаты белых идут
    # всегда ПОСЛЕ координат чёрных
    :estimate-black-pawn::black
    /\([1-8]\)B\(.*\1\)W/ {
        s//\1b\2W/
        b estimate-black-pawn::black
    }

    # → Этап 2.1
    # переводим координаты в последовательности длины X
    :estimate-black-pawn::x
    /[2-8]/ {
        s/[2-8]/1&/g
        y/2345678/1234567/

        b estimate-black-pawn::x
    }

    # → Этап 2.2
    # ищем пешки, не отсеянные на этапе 1, у которых на соседней линии слева стоят белые
    :estimate-black-pawn::left
    /\( 1*\)B\(.*\11\)W/ {
        s//\1b\2W/
        b estimate-black-pawn::left
    }

    # → Этап 2.3
    # ищем пешки, не отсеянные на этапе 2, у которых на соседней линии справа стоят белые
    :estimate-black-pawn::right
    / 1\(1*\)B\(.* \1\)W/ {
        s// 1\1b\2W/
        b estimate-black-pawn::right
    }

    # В итоге, W — белые пешки, b — чёрные, B — чёрные свободные пешки
    # избавляемся от несвободных и белых пешек
    s/ [^ ]*[Wb]//g

    # → Этап 3
    # считаем стоимости чёрных свободных пешек
    s/ 1B//; s/ 11B/ ::11111B/; s/ 111B/ :1:B/; s/ 1111B/ :1:11111B/; s/ 11111B/ :11:B/
    s/ 111111B/ :111:B/; s/ 1111111B/ 1:1111:B/; s/ 11111111B//

    # → Этап 4
    # сохраняем полученное, грузим стек обратно, вырезаем доску и оставляем чёрные пешки с координатами
    G; h; s/.*Board://; s/ .*$//; s/[a-h][1-8][^p]//g

    # оцениваем позиции всех пешек
    s/.[81]p/::B/g

    s/[abcfgh]7p/::1111B/g; s/[de]7p/::B/g

    s/[ah][65]p/::111111B/g; s/[bg][65]p/::11111111B/g; s/[cf]6p/::11B/g; s/[de]6p/:1:B/g

    s/[bg]5p/:1:11B/g; s/[cf]5p/:1:111111B/g; s/[de]5p/:11:1111B/g

    s/[ah]4p/::11111111B/g; s/[bg]4p/:1:11B/g; s/[cf]4p/:1:111111B/g; s/[de]4p/:11:1111B/g

    s/[ah][32]p/:1:11B/g; s/[bg][32]p/:1:111111B/g; s/[cf][32]p/:11:1111B/g; s/[de][32]p/:111:11B/g

    # вставляем пробелы между оценками
    s/B/& /g; s/^/ /

    # → Этап 5
    # возвращаем сохранённые оценки, убираем остатки стека
    G; s/\n\(.*\)\n.*/ \1/

    # добавляем к сохранённому стеку, вычищаем наш мусор, который мы складывали выше —
    # там второй строкой лежат оценки
    G; s/\n.*\n/ /

    b @
}

#оценочная функция для позиции чёрного короля
/@estimate-black-king()/ {
    h; s/.*Board://; s/ .*$//

    # выделяем короля
    s/[a-h][1-8][^K]//g

    # считаем его вес (матрица конца игры)
    s/[ah][18]./::/
    
    s/[de][54]./:111:111111/
    
    s/[cf][54]./:111:/; s/[de][63]./:111:/

    s/[bg][54]./:11:1111/; s/[de][72]./:11:1111/; s/[cf][63]./:11:1111/

    s/[de][18]./:1:11111111/; s/[ah][54]./:1:11111111/; s/[cf][72]./:1:11111111/; s/[bg][63]./:1:11111111/

    s/[bg][72]./:1:11/; s/[ah][63]./:1:11/; s/[cf][81]./:1:11/

    s/[a-h][1-9]./::111111/

    G; s/\n/B /

    b @
}

#оценочная функция для позиции чёрного коня
/@estimate-black-knight()/ {
    h; s/.*Board://; s/ .*$//

    # выделяем коней
    s/[a-h][1-8][^N]//g

    # считаем их вес
    s/[ah][18]./::B/g
    
    s/[de][54]./:111:11B/g
    
    s/[cf][54]./:11:11111111B/g; s/[de][63]./:11:11111111B/g

    s/[cf][36]./:11:1111B/g

    s/[bg][54]./:11:B/g; s/[de][72]./:11:B/g; s/[cf][63]./:11:B/g

    s/[de][18]./:1:B/g; s/[ah][54]./:1:B/g; s/[cf][72]./:1:B/g; s/[bg][63]./:1:B/g

    s/[bg][72]./::11111111B/g; s/[ah][63]./::11111111B/g; s/[cf][81]./::11111111B/g

    s/[a-h][1-9]./::1111B/g

    s/B/& /g; G; s/ *\n/ /

    b @
}

#оценочная функция для позиции чёрного слона
/@estimate-black-bishop()/ {
    h; s/.*Board://; s/ .*$//

    # выделяем слонов
    s/[a-h][1-8][^I]//g

    # считаем их вес
    s/[a-h][81]./:::1:1111B/g; s/[ah][1-8]./:::1:1111B/g

    s/[bg][72]./:::11:11B/g; s/[c-f][3-6]/:::11:11B/g

    s/[a-h][1-9]./:::1:11111111B/g

    s/B/& /; G; s/\n/ /

    b @
}

#оценочная функция для позиции чёрной королевы (ферзя)
/@estimate-black-queen()/ {
    h; s/.*Board://; s/ .*$//

    # выделяем ферзя и вражеского короля
    s/[a-h][1-8][^Qk]//g

    # если одной из фигур на поле нет, возврат
    /....../ ! {
        g; b @
    }

    # фигуры убираем, координаты к числам
    y/abcdefgh/12345678/; s/\([1-9]\)\(.\)./\1 \2 /g

    # группируем координаты, получится X1 X2 Y1 Y2
    s/\([^ ]\) \([^ ]\) \([^ ]\)/\1 \3 \2/

    # переводим координаты в последовательности длины значений координат
    :estimate-black-queen::xy
    /[2-8]/ {
        s/[2-8]/1&/g
        y/2345678/1234567/

        b estimate-black-queen::xy
    }        
    # сортировка — бо́льшая координата вперёд
    s/\(11*\) \(11*\1\)/\2 \1/g

    # вычитаем вторую координату из первой
    s/\(11*\)\(1*\) \1/\2/g

    # умножаем Y-координату на 8
    :estimate-black-queen::mul8
    / 1/ {
        s//88888888 /g
        b estimate-black-queen::mul8
    }
    y/8/1/

    # умножаем получившийся коэффициент на 4
    s/1/1111/g
    # группируем десятки и сотни, тысячи не нужны, максимальная оценка —
    # меньше 300
    s/1111111111/D/g; s/DDDDDDDDDD/H/g; s/\(.\)\1*/&:/g; s/[ :]*$//; y/HD/11/

    G; s/\n/B /

    b @
}

# суммированние чисел на стеке, пока не встретится слово ARRAY
/@sum-array()/ {
    h
    /ARRAY.*/ {
        s///
        s/$/ ::::::S/

        :sum-array::shift
        /[1:][1:]*B/ {
            # сложение разряда
            :sum-array::sum
            /11*B/ {
                s/\(11*\)B\(.*\)\(1*\)S/B\2\1\3S/
                s/:1111111111\(1*\)S/1:\1S/

                b sum-array::sum
            }

            # сдвиг разряда
            s/:B/B/g; s/:\(1*\)S/S \1:/

            b sum-array::shift
        }

        s/:\(1*\)S/S \1:/; s/[^1:]//g
        G; s/ARRAY/#&/; s/:\n.*#ARRAY */B /
    }

    b @
}

# вычитание чисел на стеке из первого, пока не встретится слово ARRAY
/@sub-array()/ {
    / *ARRAY.*/ {
        h; s///
        # у первого числа заменяем букву, чтобы отличать
        s/B */M /

        # у каждого числа впереди должен быть ограничитель
        s/^/:/; s/ / :/g

        # у первого числа снимаем самый младший разряд
        s/:\(1*\)\(M.*\)/:\2 :\1#S/
        :sub-array::loop

        # теперь пройдёмся по младшим разрядам оставшихся чисел
        :sub-array::minus
        /:\(11*\)\(B.*\) :\1\(1*\)#S/ {
            s//:\2 :\3#S/
            b sub-array::minus
        }

        # младшие разряды для вычитания остались?
        /:11*B/ {
            # переносим разряды вычитаемого на младший
            :sub-array::cy
            # если переносить нечего, то всё, получается число меньше нуля,
            # возвращаем ноль, выходим
            /1.*M/ ! {
                s/.*/:::B/
                b sub-array::end
            }

            s/\(.*\)1:\(.*M\)/\1:1111111111\2/

            /1M/ ! b sub-array::cy

            # добавляем к вычитаемому
            s/:\(1*\)\(M.*\) \(:.*\)#S/:\2 \3\1#S/

            b sub-array::minus
        }

        # срезаем у всех по пустому теперь разряду, у тех, у кого их не осталось, убираем
        s/:\([BM]\)/\1/g; s/ :*B//g

        # берём следующий разряд
        s/:\(1*\)\(M.*\) \([^ ]*\)#S/:\2 :\1#S \3S/

        # если осталось что вычитать, вычитаем
        /B/ b sub-array::loop

        # убираем лишнее, нормализируем
        s/[#MS ]//g; s/://

        :sub-array::end

        G; s/ARRAY/#&/; s/\n.*#ARRAY */B /
    }

    b @
}

# выбор указанной фигуры (вернётся в виде строки)
# XYF__XYF__ где F — наименование фигуры, __ — место под перебор позиции
/@select-figures(.)/ {
    h
    # убираем из данных всё лишнее, параметр помечаем маркером
    s/@select-figures(\(.\))\(.*\)/\2 Selected:\1/
    s/.*Board://
    s/ .*Selected:/ Selected:/

    # выделяем из доски то, что указал пользователь
    :select-figures::select
    /\([a-h][0-9]\)\(.\)\(.* Selected:\2\)/ {
        s//\3\1\2__/
        b select-figures::select
    }

    # убираем маркер и изувеченную доску
    s/.*Selected:.//

    # возвращаем стек назад
    G; s/\n/END /
    b @
}

/@iter-knight()/ {
    # убираем коня, который ход закончил
    s/^...XX//
    # выходим, если ходить нечем
    /^END/ b @

    # выделяем первого коня
    h; s/\(.....\).*/\1/

    # кодировка ходов: __ — не был сделан, XX — сделаны все возможные
    # Left, Down, Up, Right, первым пишется ход на две клетки, например:
    # LU — влево на две, вверх на одну

    /__/ {
        s//LU/
        # сдвигаем координату X-2, Y+1, 0 — признак, что ход невозможен
        y/abcdefgh/00abcdef/
        y/12345678/23456780/

        b common::go
    }

    /LU/ {
        s//UL/
        # X-1, Y+2
        y/abcdefgh/0abcdefg/
        y/12345678/34567800/

        b common::go
    }

    /UL/ {
        s//UR/
        # X+1, Y+2
        y/abcdefgh/bcdefgh0/
        y/12345678/34567800/

        b common::go
    }

    /UR/ {
        s//RU/
        # X+2, Y+1
        y/abcdefgh/cdefgh00/
        y/12345678/23456780/

        b common::go
    }

    /RU/ {
        s//RD/
        # X+2, Y-1
        y/abcdefgh/cdefgh00/
        y/12345678/01234567/

        b common::go
    }

    /RD/ {
        s//DR/
        # X+1, Y-2
        y/abcdefgh/bcdefgh0/
        y/12345678/00123456/

        b common::go
    }

    /DR/ {
        s//DL/
        # X-1, Y-2
        y/abcdefgh/0abcdefg/
        y/12345678/00123456/

        b common::go
    }

    /DL/ {
        s//XX/
        # X-2, Y-1
        y/abcdefgh/00abcdef/
        y/12345678/01234567/

        b common::go
    }

    b common::go
}

# король ходит на одну клетку куда угодно              N
# кодировка по сторонам света                        W   E
# __ → NN → EN → EE → SE → SS → WS → WW → NW → XX      S
/@iter-king()/ {
    # убираем короля, который ход закончил
    s/^...XX//
    # выходим, если ходить нечем
    /^END/ b @

    # выделяем первого (и единственного) короля
    h; s/\(.....\).*/\1/

    # текущую выбранную позицию меняем на следующую
    s/$/ __NNENEESESSWSWWNWXX/
    s/\(..\) \(.*\1\)\(..\)/\3 \2\3/; s/ .*//

    # заменяем координты, согласно выбранной позиции

    # Y+1
    /N/ y/12345678/23456780/
    # Y-1
    /S/ y/12345678/01234567/
    # X-1
    /W/ y/abcdefgh/0abcdefg/
    # X+1
    /E/ y/abcdefgh/bcdefgh0/

    b common::go
}

# ладья, ходит по вертикали или горизонтали на любое количество ходов,   N
# если никто не стоит на пути                                          W   E
# ходит начинаем с текущей координаты в указанную сторону                S
/@iter-rook()/ {
    # убираем ладью, которая ход закончила
    s/^...XX//
    # выходим, если ходить нечем
    /^END/ b @

    # выделяем первую ладью
    h; s/\(.....\).*/\1/

    # первое наше направление — восток, потом идём по следующим направлениям
    /__/ s/\(\(.\).*\)__/\1E\2/
    /E0/ s/\(\(.\).*\)E./\1W\2/
    /W0/ s/\(.\(.\).*\)W./\1N\2/
    /N0/ s/\(.\(.\).*\)N./\1S\2/
    s/S0/XX/

    /E/ y/abcdefgh/bcdefgh0/
    /W/ y/abcdefgh/0abcdefg/
    
    /S/ y/12345678/01234567/
    /N/ y/12345678/23456780/

    # переписываем состояние в координаты выбранной фигуры, так как фигура хода пропадёт
    /[SN]/ s/\(.\).\(..\(.\)\)/\1\3\2/
    /[WE]/ s/.\(...\(.\)\)/\2\1/

    /[0X]/ ! {
        # возвращаем стек, убираем всё, что за и перед доской на стеке
        s/$/#/; G; s/\n.*\(Board:[^ ]*\).*/\1/

        # проверка, не стоит ли на выбранной позиции своя фигура, если стоит, прекращаем скан сразу
        s/^\(..\)R\(.\).*\(\1[PQKINR]\).*/00R\20#\3/
        # если же там стоит чужая фигура, то двигаться можно, а ходить за неё — нет
        s/^\(..\)R\(.\).*\(\1[pqkinr]\).*/\1R\20#\3/

        s/#.*//
    }

    b common::go
}

# слон (офицер) ходит по диагонали, при условии, что на пути нет фигур
# ходить начинаем с текущего места, обозначения направлений: ↘ (v), ↖ (^), ↗ (+), ↙ (-)
# обозначение хода выглядит так: ↙8 — отошли от текущей позиции на 8 шагов
/@iter-bishop()/ {
    # убираем слона, который ход закончил
    s/^...XX//
    # выходим, если ходить нечем
    /^END/ b @

    # выделяем первого слона
    h; s/\(.....\).*/\1/

    # текущую выбранную позицию меняем на следующую
    s/$/ __v①v0^①^0+①+0-①-0XX/
    s/\(..\) \(.*\1\)\(..\)/\3 \2\3/; s/ .*//

    # переведём десятичное число в количество стрелок, сохранив текущее состояние 
    H
    :iter-bishop::tobin
    /[0X]/ ! {
        y/①②③④⑤⑥⑦⑧/0①②③④⑤⑥⑦/
        s/.$/&→/
        b iter-bishop::tobin
    }

    :iter-bishop::minus
    # вычисляем координаты
    /→/ {
        s///

        # X-1
        /[\-\^]/ y/abcdefgh/0abcdefg/
        # X+1
        /[+v]/ y/abcdefgh/bcdefgh0/
        # Y-1
        /[\-v]/ y/12345678/01234567/
        # Y+1
        /[+\^]/ y/12345678/23456780/

        b iter-bishop::minus
    }

    # возращаем то состояние, которое было, сейчас у нас: стек, \n, исходное состояние, \n, вычисленное
    # с испорченным номером хода

    # вычищаем из стека лишние данные — их отправляем в хранилище
    H; x; s/\n/#/; h; s/#.*//

    # меняем местами, теперь в хранилище у нас чистый стек, а у нас: исходное \n испорченное
    x; s/.*#//

    # переносим координаты из испорченного в исходное (в испорченном мы вычислили координаты хода),
    # испорченное состояние уничтожаем
    s/..\(.*\)\n\(..\).*/\2\1/

    /[0X]/ ! {
        # возвращаем стек, убираем всё, что за и перед доской на стеке
        s/$/#/; G; s/\n.*\(Board:[^ ]*\).*/\1/
        # проверка, не стоит ли на выбранной позиции своя фигура, если стоит, прекращаем скан сразу
        s/^\(..\)I\(.\).*\(\1[PQKINR]\).*/00I\20#\3/
        # если же там стоит чужая фигура, то двигаться можно, а ходить за неё — нет
        s/^\(..\)I\(.\).*\(\1[pqkinr]\).*/\1I\20#\3/
        s/#.*//
    }

    b common::go
}

# перемещаем позицию и сумму в конец стека,
# перекладываем счётчик позиции фигуры
/@store-iter()/ {
    # если ходить было нельзя, вычищаем мусор
    /^[^ ]* *0..../ {
        s///
        b @
    }

    # (оценка позиции) (фигура хода) счётчик позиции (текущая фигура) всё остальное →
    # текущая фигура, всё остальное, сумма, ход откуда→ход куда
    s/\([^ ]*\) *\(...\)..\(...\)\([^ ]*END *.*\)/\3\4 \1(\3→\2)/
    b @
}

# вычисление лучшего хода из указанных
/@find-best-move()/ {
    # есть ли оценки (больше одной причём)?
    /[1:][1:]*B/ {
        h
        # убираем лишнее
        s//Moves:&/; s/.*Moves:/ /

        # нормализация числа
        s/ / :::::/g; s/ :*\(1*:1*:1*:1*:1*B\)/ \1/g

        y/B/:/

        :find-best-move::cut
        # смотрим, есть ли числа с непустым старшим разрядом
        / 1/ {
            # если есть, то убираем те, у которых страший разряд пустой
            s/ :[^ ]*//g
            # теперь отрезаем у каждого по одной цифре старшего разряда
            s/ 1/ /g
            b find-best-move::cut
        }
        # переход через разряд, есть ли ещё числа с разрядами?
        s/ :/ /g
        /:/ b find-best-move::cut

        # если было несколько максимумов, оставляем только первый
        s/^ *\([^ ]*\).*/\1/
        # возвращаем данные на основной стек
        G; s/\n/ /

        # маркируем место, где у нас находятся оценки
        s/[1:][1:]*B/Moves: &/

        # теперь, если на стеке запись вида (XYF→XYF), дописываем к ней оценку
        s/^\(([^)]*\)\(.* \)\([1:][1:]*B\1\)/\3\2/

        # убираем ненужные теперь оценки
        s/ *Moves:.*//
        # теперь на стеке запись вида Est(XYF→XYF), либо такой записи вообще нет (если не было возможных ходов у фигуры)
    }

    b @
}

# ход чёрных, согласно найденным данным
/@move-black()/ {
    # убираем с позиции куда будем ходить фигуру, что бы там не стояло, удаляем это
    s/\([1:][1:]*B(\(..\)\(.\)→\(..\).).*Board:.*\)\4./\1\2 /
    # меняем координаты фигуры, которой ходим
    s/[1:][1:]*B(\(..\)\(.\)→\(..\).) *\(.*Board:.*\)\1\2/\4\3\2/

    b @
}

# просчёт ходов пешки. На стеке должны быть: начальная оценка по пешкам
# (сюда будет складываться максимум) и выписаны все пешки
# чёрные пешки умеют ходить по 4м направлениям:
# 1) на 1 ход (D1)
# 2) на 2 до середины доски, если поле перед ней не занято (D2)
# 3) вниз влево, если там чужая фигура (DL)
# 4) вниз вправо, если там чужая фигура (DR)
# кроме того, пешка, достигая края доски, имеет право превратиться в любую фигуру (кроме короля)



/@ *$/ {
    q
}

b @

# хождение фигурой
:common::go
# возвращаем стек
G; s/\n//
# переписываем куда мы уже ходили в текущую фигуру
# XYFPPXYF.. → XYF__XYPP
s/\(...\)\(..\)\(...\)../\1__\3\2/

# данные о фигурах и доска, остальное убираем
s/^\([^ ]*END\).*\(Board:[^ ]*\).*/\1 \2/
# смотрим нет ли на предполагаемом поле нашей собственной фигуры
s/^\(..\)\(.*\1[PQKINR]\)/00\2/

# если во второй координате ноль, ставим ноль и в первую
s/^.0/00/

# если ходить сюда можно, ходим
/^0/ ! {
    # XY Фигура хода XY Фигура текущая
    # меняем координаты фигуры, которая ходит
    s/\(\(...\)__\(...\).*Board:.*\)\3/\1\2/
    # меняем координаты того места куда ходим, съедая по пути фигуру
    s/\(..\)\(.__\)\(..\)\(.*Board:.*\)\1./\1\2\3\4\3N/
}

# стек возвращаем, убирая с него второй (оставшийся) стек выделенных фигур
G; s/\n[^ ]* */ /

# меняем нашу добавленную и последнюю доску местами
s/\(Board:[^ ]*\)\(.*\)\(Board:[^ ]*\)/\3\2\1/

b @