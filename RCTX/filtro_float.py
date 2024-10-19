import numpy as np
rng = np.random.default_rng()
from filter_tools import rcosine
from filter_tools import resp_freq
from filter_tools import eyediagram
import random
import matplotlib.pyplot as plt

## Generacion de las PRBS
# seed_PRBS9I = 110101010 #9'h1AA
# random.seed(seed_PRBS9I) 
# PRBS9I = [random.randrange(0, 2) for _ in range(512)]
# seed_PRBS9Q = 111111110 #9'h1FE
# random.seed(seed_PRBS9Q)
# PRBS9Q = [random.randrange(0, 2) for _ in range(512)]

# In[1]: Parametros y generacion del pulso:

## Parametros generales para generar el pulso
T     = 1.0/100.0e6 # Periodo de baudio
Nsymb = 1000        # Numero de simbolos
os    = 4           # Oversampling
## Parametros de la respuesta en frecuencia
Nfreqs = 256        # Cantidad de frecuencias
## Parametros del filtro de caida cosenoidal
beta   = 0.5        # Roll-Off
Nbauds = 6          # Cantidad de baudios del filtro
## Parametros funcionales
Ts = T/os           # Frecuencia de muestreo

##? Calculo del pulso
(t,rc0) = rcosine(beta,T,os,Nbauds,Norm=False)
# plt.plot(t,rc0)
# print('Coeficientes del filtro: ')
print(rc0)

# In[2]: Generacion de la Rta en frecuencia del pulso

##? Rta en frecuencia
[H0,A0,F0] = resp_freq(rc0, Ts, Nfreqs)
##? Generacion del grafico de la rta en frecuencia
plt.figure(1,figsize=[14,6])
plt.semilogx(F0, 20*np.log10(H0),'r', linewidth=2.0, label=r'$\beta=0.5$')
plt.axvline(x=(1./Ts)/2.,color='k',linewidth=2.0)           # fs/2 lim de Nyquist
plt.axvline(x=(1./T)/2.,color='k',linewidth=2.0)            # f del clock
plt.axhline(y=20*np.log10(0.5),color='k',linewidth=2.0)     # -3dB para la fc
plt.legend(loc=3)
plt.grid(True)
plt.title('Respuesta en frecuencia del filtro')
plt.xlabel('Frequencia [Hz]')
plt.ylabel('Magnitud [dB]')
plt.show()

# In[3]: Generacion de PRBS con oversampling y grafico de bits transmitidos

##? Generacion de la PRBS
symbolsI = 2*(np.random.uniform(-1,1,Nsymb)>0.0)-1
symbolsQ = 2*(np.random.uniform(-1,1,Nsymb)>0.0)-1
##? Aplico el oversampling
zsymbI = np.zeros(os*Nsymb) 
zsymbI[1 : len(zsymbI) : int(os)] = symbolsI
zsymbQ = np.zeros(os*Nsymb) 
zsymbQ[1 : len(zsymbQ) : int(os)] = symbolsQ
##? Grafico de los bits transmitidos
plt.figure(2,figsize=[10,6])
plt.subplot(2,1,1)
plt.plot(zsymbI,'o')
plt.xlim(0,20)
plt.grid(True)
plt.legend()
plt.title('Bits transmitidos en fase')
plt.subplot(2,1,2)
plt.plot(zsymbQ,'o')
plt.xlim(0,20)
plt.grid(True)
plt.legend()
plt.title('Bits transmitidos en cuadratura')
plt.show()

# In[4]: Salida del filtro

##? Convolucion con el filtro
symb_out0I = np.convolve(rc0,zsymbI,'same')
symb_out0Q = np.convolve(rc0,zsymbQ,'same')
##? Salida del filtro
plt.figure(3,figsize=[10,6])
plt.subplot(2,1,1)
plt.plot(symb_out0I,'r-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta)
plt.xlim(1000,1250)
plt.grid(True)
plt.legend()
plt.title('Salida del filtro en fase')
plt.ylabel('Magnitud')
plt.subplot(2,1,2)
plt.plot(symb_out0Q,'r-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta)
plt.xlim(1000,1250)
plt.grid(True)
plt.legend()
plt.title('Salida del filtro en cuadratura')
plt.xlabel('Muestras')
plt.ylabel('Magnitud')
plt.show()

# In[5]: Diagrama de ojo a la salida del filtro

##? Generacion del diagrama de ojo
eyediagram(symb_out0I[100:len(symb_out0I)-100],os,5,Nbauds)
plt.legend()
plt.title('Diagrama de ojo en fase')
plt.show()
eyediagram(symb_out0Q[100:len(symb_out0Q)-100],os,5,Nbauds)
plt.legend()
plt.title('Diagrama de ojo en cuadratura')
plt.show()

# In[6]: Constelacion a la salida del filtro

##? Constelacion
offset = 1
plt.figure(figsize=[6,6])
plt.plot(symb_out0I[100+offset:len(symb_out0I)-(100-offset):int(os)],
         symb_out0Q[100+offset:len(symb_out0Q)-(100-offset):int(os)],
             '.',linewidth=2.0)
plt.xlim((-2, 2))
plt.ylim((-2, 2))
plt.grid(True)
plt.legend()
plt.title('Constelacion')
plt.xlabel('Real')
plt.ylabel('Imag')
plt.show()

# In[7]: Calculo del BER

##? Separo las fases y verifico cada una
fase1I = np.zeros(len(symbolsI))
fase2I = np.zeros(len(symbolsI))
fase3I = np.zeros(len(symbolsI))
fase4I = np.zeros(len(symbolsI))
fase1Q = np.zeros(len(symbolsQ))
fase2Q = np.zeros(len(symbolsQ))
fase3Q = np.zeros(len(symbolsQ))
fase4Q = np.zeros(len(symbolsQ))

for i in range(0,len(symbolsI)):
    fase1I[i] = symb_out0I[4*i + 0]
    fase2I[i] = symb_out0I[4*i + 1]
    fase3I[i] = symb_out0I[4*i + 2]
    fase4I[i] = symb_out0I[4*i + 3]
    fase1Q[i] = symb_out0Q[4*i + 0]
    fase2Q[i] = symb_out0Q[4*i + 1]
    fase3Q[i] = symb_out0Q[4*i + 2]
    fase4Q[i] = symb_out0Q[4*i + 3]


correl = np.zeros(len(symbolsI))
t = range(0,len(symbolsI))
for k in range(0,len(symbolsI)):
    for n in range(k,len(symbolsI)):
        correl[k] = fase1I[n]*symbolsI[n-k]
plt.plot(t,correl)

# %%
correl = np.zeros(len(symbolsI))
t = range(0,len(symbolsI))
for k in range(0,len(symbolsI)):
    for n in range(k,len(symbolsI)):
        correl[k] = fase2I[n]*symbolsI[n-k]
plt.plot(t,correl)
# %%
