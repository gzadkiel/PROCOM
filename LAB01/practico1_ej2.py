import numpy as np
import ast

def calculdora():
    while True:
        # Intro and option select
        print('Las posibles operaciones a realizar son: ')
        print('1 - Suma')  
        print('2 - Resta')
        print('3 - Producto')
        print('4 - Division')
        print('5 - Iterar')
        print('6 - Producto punto')
        print('Ingrese la palabra exit para salir')
        opt = input('Ingrese el numero correpondientea a la operacion que desea realizar: ')

        # Input values for each case
        if(opt == '1' or opt == '2' or opt == '3'):
            print('Ingrese los valores para realizar la operacion:')
            a = float(input('Primer valor: '))
            b = float(input('Segundo valor: '))
            match opt:
                case '1':
                    resultado = a + b
                case '2':
                    resultado = a - b
                case '3':
                    resultado = a * b
            resultado_final = round(resultado,2)
            print('El resultado es:', resultado_final)
        elif(opt == '4'):
            print('Ingrese los valores para realizar la operacion:')
            a = float(input('Dividendo: '))
            b = float(input('Divisor: '))
            resultado = a / b
            resultado_final = round(resultado,2)
            print('El resultado es:', resultado_final)
        elif(opt == '5'):
            print('Operacion a realizar de forma iterativa:')
            print('a - Suma')
            print('b - Resta')
            print('c - Producto')
            opt_2 = input('Seleccione la operacion a realizar: ')
            
            print('Ingrese el paso y el numero de iteraciones:')
            a = float(input('Paso: '))
            b = int(input('Iteraciones: '))
            resultado = 0
            match opt_2:
                case 'a':
                    for i in range(b):
                        resultado = resultado + a
                case 'b':
                    for i in range(b):
                        resultado = resultado - a
                case 'c':
                    resultado = a**b
                case _: 
                    print('Error')
            resultado_final = round(resultado,2)
            print('El resultado es:', resultado_final)
        elif(opt == '6'):
            while True:
                print('Ingrese las matrices con las que se desea operar:')
                print('El producto se realiza como: AxB')
                print('Un vector fila se ingresa como: [1, 2, 3, 4]')
                print('Un vector columna se ingresa como: [[1], [2], [3], [4]]')
                a = ast.literal_eval(input('Matriz A: '))
                b = ast.literal_eval(input('Matriz B: '))
                # Convert inputs to np arrays
                matA = np.asarray(a)
                matB = np.asarray(b)
                print(matA.shape)
                print(matB.shape)
                # Check compatible sizes
                (rowsA, colsA) = matA.shape
                (rowsB, colsB) = matB.shape
                if(colsA == rowsB):
                    mat_resultado = np.dot(matA,matB)
                    break
                else:
                    print('ERROR: No se puede realizar el producto')
                    print('Revise el tamaño de las matrices')
                    continue
            resultado_final = mat_resultado
            print('El resultado es:', resultado_final)
        elif(opt == 'exit'):
            print('Saliendo...')
            break
        else:
            print('La opcion ingresa no existe.')
            continue
    
    return

#calculdora()