# NSEE libraries

This repository contains libraries and utilities created by *Núcleo de sistemas eletrônicos embarcados* (NSEE) at Instituto Mauá de Tecnologia.

### Proprietary functions
- pyCreate

---
## pyCreate 

This simulink script compiles and creates Cython files for a given Simulink subsystem. This allows the user to use the subsystem as a function or a class within the python environment.

#### Python class

The python class will have the same name as the Simulink subsystem block and will contain the following methodes:
```{python}
__init__(self)
```
```{python} 
start()
```
```{python}
update(reference, feedback)
```
```{python}
output()
```
```{python}
terminate()
```

#### Python function

The python will have the same name as the Simulink subsystem block and will contain the following methodes:
```{python}
Initialize()
```
```{python} 
Step()
```
```{python}
update(reference, feedback)
```
```{python}
Next(output)
```

```{python}
Set_U(reference, feedback)
```

```{python}
Terminate()
```
