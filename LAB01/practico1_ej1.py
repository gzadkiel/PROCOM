def calculdora():

    # Intro and option select
    print('Las posibles operaciones a realizar son: ')
    print('1 - Suma')  
    print('2 - Resta')
    print('3 - Producto')
    print('4 - Division')
    print('5 - Iterar')
    opt = int(input('Ingrese el numero correpondientea a la operacion que desea realizar: '))

    # Input values for each case
    if(opt == 1 or opt == 2 or opt == 3):
        print('Ingrese los valores para realizar la operacion:')
        a = float(input('Primer valor: '))
        b = float(input('Segundo valor: '))
        match opt:
            case 1:
                resultado = a + b
            case 2:
                resultado = a - b
            case 3:
                resultado = a * b
    elif(opt == 4):
        print('Ingrese los valores para realizar la operacion:')
        a = float(input('Dividendo: '))
        b = float(input('Divisor: '))
        resultado = a / b
    elif(opt == 5):
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

    else:
        print('La opcion ingresa no existe.')

    return round(resultado,2)

res_final = calculdora()
print('El resultado es:', res_final)
