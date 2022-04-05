; TP 11 Padron 107143 Gonzalo Manuel Calderon
; Implementacion del algoritmo de cifrado Playfair
; El archivo a leer debe ser en formato binario, usando cada caracter 1 byte
; La matriz debe contener todas las letras del alfabeto exceptuando la J, apareciendo
; Cada una de estas una unica vez.
; El formato en el que se debe guardar la matriz es como se muestra en el archivo matriz.dat, debe ser el siguiente:
; abcde 
; fghik
; lmnop
; qrstu
; vwxyz
; El programa se encargara de validar dicha matriz, al igual que el resto de los datos que recibe por el usuario.

global main
extern printf
extern gets
extern fopen
extern fread
extern fclose




section .data
    handleFile dq 0
    fileLocation db "matriz.dat",0
    mode db "rb",0
    contador dq 0
    newline_contador dq 0
    posCol1 dq 1
    posFil1 dq 1
    posCol2 dq 1
    posFil2 dq 1
    tempCol dq 1
    tempFil dq 1
    cargaEsValida db "S",0
    opValido db "S",0
    charEsValido db "S",0
    charEncontrado db "S",0
    matriz db "abcdefghiklmnopqrstuvwxyz",0
    charsvisitados db "*************************",0
    msjOpDeseada db "Ingrese C en caso de querer cifrar y D si desea descifrar: ",0
    msjOpError db "La operacion ingresada es invalida.",10,0
    msjCadena db "Ingrese una cadena valida(Limite de 100 caracteres): ",0
    msjmatrizError db "Error al abrir el archivo que contiene la matriz",10,0
    msjCadError db "La cadena ingresada es invalida (Deben ser caracteres entre A-Z sin contar la J)",10,0
    msjResultado db "La cadena %s es: %s",10,0
    msjCifrado db "cifrada",0
    msjDecifrado db "decifrada",0
    indice1 dq 0
    indice2 dq 1
    indNuevoStr dq 0
    desp dq 0

section .bss
    opElegida resb 1
    cadena resb 100
    cadenaMod resb 100
    letra1 resb 2
    letra2 resb 2
    letraAct resb 2
    tempMatriz resb 26


section .text
main:

    call cargarMatriz
    cmp byte[cargaEsValida],"N"
    je fin


ingresoOp:
    mov byte[opValido],"S"

    mov rdi,msjOpDeseada
    sub rax,rax
    call printf

    mov rdi,opElegida
    call gets

    call validarOp

    cmp byte[opValido],"N"
    je ingresoOp

ingresoCadena:
    mov byte[charEsValido],"S"
    mov rdi,msjCadena
    sub rax,rax
    call printf

    mov rdi,cadena
    call gets

    cmp byte[cadena + 1],0 ; En caso de que la cadena ingresada es un unico caracter, lo tomamos como invalido.
    je errorBloque
iterCifrado:

    mov rsi,[indice1]
    cmp byte[cadena+rsi],0
    je mostrarRes

    mov rsi,[indice2]
    cmp byte[cadena + rsi],0
    je agregarUlt ; En caso de que la palabra tiene longitud impar se debe agregar el ultimo caracter que no fue cifrado.
    
    call selecLetras

validarLetras:

    mov al,[letra1]
    call validarChar
    cmp byte[charEsValido],"N"
    je ingresoCadena

    mov al,[letra2]
    call validarChar
    cmp byte[charEsValido],"N"
    je ingresoCadena


hallarPos:
; Se buscan ambas letras en la matriz y se guardan sus posiciones.
    mov al,[letra1]
    call buscarEnMatriz

    mov [posFil1],rax
    mov [posCol1],rdx

    mov al,[letra2]
    call buscarEnMatriz
    
    mov [posFil2],rax
    mov [posCol2],rdx


encontrarCaso:
    mov rax,[posCol1]
    cmp [posCol2],rax
    je casoColIguales

    mov rax, [posFil1]
    cmp [posFil2],rax
    je casoFilIguales
    
    ; En caso de que no entre en ninguna de las condiciones anteriores tienen todas sus posiciones distintas
    ; Tanto para cifrado como decifrado es la misma operacion.
    mov rax,[posCol1]
    mov rcx,[posCol2]
    mov [posCol2],rax
    mov [posCol1],rcx


cargarCaracteres:

    mov rax,[posFil1]
    mov rdx,[posCol1]
    call buscarDesp
    mov rsi,rax

    mov cl,[matriz+rsi]
    mov rbx,[indNuevoStr]
    mov [cadenaMod+rbx],cl

    inc qword[indNuevoStr]

    mov rax,[posFil2]
    mov rdx,[posCol2]
    call buscarDesp
    mov rsi,rax

    mov cl,[matriz+rsi]
    mov rbx,[indNuevoStr]
    mov [cadenaMod+rbx],cl

    inc qword[indNuevoStr]
    
    jmp iterCifrado


mostrarRes:
    cmp byte[opElegida],"C"
    je mostrarCifrado

    jmp mostrarDecifrado
fin:
    mov rdi,[handleFile]
    call fclose
ret


;+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+
;################################### RUTINAS INTERNAS ################################## 
;+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+-+--+--+--+


mostrarDecifrado:
    sub rax,rax
    mov rdi,msjResultado
    mov rsi,msjDecifrado
    mov rdx,cadenaMod
    call printf

    jmp fin

mostrarCifrado:
    sub rax,rax
    mov rdi,msjResultado
    mov rsi,msjCifrado
    mov rdx,cadenaMod
    call printf

    jmp fin



selecLetras:
    ;seleciona las proximas letras de la cadena a cifrar
    mov rsi,[indice1]
    mov al,[cadena+rsi]
    mov [letra1],al
    add qword[indice1],2 ; aumenta el indice para la prox iter

    mov rsi,[indice2]
    mov al,[cadena+rsi]
    mov [letra2],al
    add qword[indice2],2

ret

errorBloque:
    call errorChar
    jmp ingresoCadena


charInvalido:

    call errorChar

    mov byte[charEsValido],"N"
    jmp validarCharFin

OpError:
    mov rdi,msjOpError
    sub rax,rax
    call printf
    mov byte[opValido],"N"
    jmp validarOpFin


errorChar:
    mov rdi,msjCadError
    sub rax,rax
    call printf

    mov qword[indice1],0
    mov qword[indice2],1
    mov qword[indNuevoStr],0
    mov qword[cadenaMod],0
ret


buscarDesp:
;Calcula la posicion del caracter indicado por la col y la fil
    sub rax,1 ; (i-1)[i = fil]
    imul rax,5 ; (i-1)*longFila
    sub rdx,1 ; (j-1)*longElem[Es 1]
    add rax,rdx ; (i-1)*5 + (j-1)*1
ret

buscarEnMatriz:
    ; Iniciamos la busqueda en el primer caracter de la matriz
    mov qword[tempFil],1
    mov qword[tempCol],1
    mov [letraAct],al

iterMatriz:
    cmp qword[tempFil],6
    je charNoEncontrado

    mov rax,[tempFil]
    mov rdx,[tempCol]
 
    call buscarDesp
    mov rsi,rax
    mov [desp],rax ; Guardamos el desplazamiento calculado para poder usarla una vez terminada la rutina.
    
    mov al,[matriz+rsi]
    cmp byte[letraAct],al
    je busqTerminada
    cmp qword[tempCol],5
    je sigFil
    add qword[tempCol],1
    jmp iterMatriz

busqTerminada:
    mov rax,[tempFil]
    mov rdx,[tempCol]
ret




sigFil:
    mov qword[tempCol],1
    inc qword[tempFil]
    jmp iterMatriz


casoColIguales:
    mov rax,[posFil1]
    cmp [posFil2],rax
    je errorBloque

    cmp byte[opElegida],"D"
    je decifrarCol

cifrarCol:
    cmp qword[posFil1],5
    je moverPrimFil1
    inc qword[posFil1]

    cmp qword[posFil2],5
    je moverPrimFil2

avanzarSigFil2:
    inc qword[posFil2]
    jmp cargarCaracteres

moverPrimFil1:
    mov qword[posFil1],1
    jmp avanzarSigFil2

moverPrimFil2:
    mov qword[posFil2],1
    jmp cargarCaracteres



decifrarCol:
    cmp qword[posFil1],1
    je moverUltFil1
    dec qword[posFil1]

    cmp qword[posFil2],1
    je moverUltFil2
decifCol2:
    dec qword[posFil2]
    jmp cargarCaracteres

moverUltFil1:
    mov qword[posFil1],5
    jmp decifCol2

moverUltFil2:
    mov qword[posFil2],5
    jmp cargarCaracteres



casoFilIguales:
    cmp byte[opElegida],"D"
    je decifrarFil
cifrarFil:
    cmp qword[posCol1],5
    je moverPrimCol1
    inc qword[posCol1]
    
    cmp qword[posCol2],5
    je moverPrimCol2

avanzarSigCol2:
    inc qword[posCol2]
    jmp cargarCaracteres

moverPrimCol1:
    mov qword[posCol1],1
    jmp avanzarSigCol2 

moverPrimCol2:
    mov qword[posCol2],1
    jmp cargarCaracteres 



decifrarFil:
    cmp qword[posCol1],1
    je moverUltCol1
    dec qword[posCol1]

    cmp qword[posCol2],1
    je moverUltCol2

decifrarChar2:
    dec qword[posCol2]
    jmp cargarCaracteres

moverUltCol1:
    mov qword[posCol1],5
    jmp decifrarChar2

moverUltCol2:
    mov qword[posCol2],5
    jmp cargarCaracteres



agregarUlt:
    mov rsi,[indNuevoStr]
    mov al,[cadena+rsi]
    call validarChar
    cmp byte[charEsValido],"N"
    je ingresoCadena
    mov [cadenaMod+rsi],al
    inc rsi
    mov byte[cadenaMod+rsi],0
    jmp mostrarRes


matrizError:
    mov rdi,msjmatrizError
    sub rax,rax
    call printf
    mov byte[cargaEsValida],"N"
    jmp cargaTerminada

charNoEncontrado:
    mov byte[charEncontrado],"N"
    jmp busqTerminada




cargarMatriz:
;Esta rutina interna se encarga de leer, validar y cargar la matriz.
openFile:
    mov rdi,fileLocation
    mov rsi,mode ; Debe leer en formato binario ya que necesitamos considerar los saltos de linea.
    call fopen
    cmp rax,0
    jle matrizError
    mov qword[handleFile],rax

leerArchivo:
    mov rdi,letraAct
    mov rsi,1
    mov rdx,1
    mov rcx,[handleFile]
    call fread    

    cmp rax,0
    jle actualizarMatriz

    cmp qword[newline_contador],5
    je verificarNewLine

    mov al,[letraAct]
    call buscarEnMatriz ; Buscamos en la matriz guardada por default el caracter actual de la nueva matriz.
    cmp byte[charEncontrado],"N"
    je matrizError

    mov rsi,[desp]

    cmp byte[charsvisitados + rsi],"1"
    je matrizError

    mov byte[charsvisitados + rsi],"1" ; Marcamos el caracter actual como leido en los visitados
    mov rsi,[contador]
    mov al,[letraAct]
    mov [tempMatriz + rsi],al ; Cargamos el caracter en la matriz temporal
    inc qword[contador]
    inc qword[newline_contador]
    jmp leerArchivo

actualizarMatriz:
    cmp qword[contador],25 ; La cantidad de letras de A-Z sin J es 25 y la nueva matriz debe cumplir con esa cantidad
    jne matrizError

    mov rsi,[contador]
    mov byte[tempMatriz + rsi],0 ; Agregamos el 0 que indica el fin del string.

	mov	rcx,26
	mov	rsi,tempMatriz
	mov	rdi,matriz
	rep	movsb ; Actualizamos la matriz a la ingresada por el usuario.

cargaTerminada:
ret

validarOp:
    mov rsi,1
    mov al,[opElegida+rsi]
    cmp al,0 ; verifica que la cadena es de largo 1
    jne OpError

    cmp byte[opElegida],"C"
    je validarOpFin

    cmp byte[opElegida],"D"
    je validarOpFin

    jmp OpError

validarOpFin:
ret

validarChar:
; Realiza una validacion por rango sobre el char que se encuentre en al.
    cmp al,"j"
    je charInvalido
    cmp al,"a"
    jl charInvalido
    cmp al,"z"
    jg charInvalido

validarCharFin:
ret


verificarNewLine:
    cmp byte[letraAct],0ah
    jne matrizError 
    mov qword[newline_contador],0

    jmp leerArchivo 