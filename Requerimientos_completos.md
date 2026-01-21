**Especificación de Requerimientos de Software (SRS)** 

1. **Introducción** 

Esta sección proporciona una visión general del sistema, sus objetivos, alcance, público objetivo y definiciones relevantes. 

1. **Propósito** 

Describir los requerimientos funcionales y no funcionales del sistema de gestión para una urbanización privada, incluyendo registro de propietarios, control de acceso y administración de residentes. 

2. **Alcance**

El sistema permitirá registrar propietarios, gestionar residentes, administrar accesos, generar reportes y mantener la integridad de la información en el entorno residencial. 

3. **Definiciones, siglas y abreviaturas** RF: Requerimiento Funcional 

   RNF: Requerimiento No Funcional 

   SRS: Software Requirements Specification 

2. **Descripción general del sistema** 

El sistema gestionará la información de propietarios, residentes, guardias y accesos de una urbanización privada, asegurando la trazabilidad y consistencia de los datos. 

1. **Perspectiva del sistema** 

El sistema se compone de módulos: Registro de Propietarios, Gestión de Residentes, Control de Accesos, Administración de Viviendas y Reportes. 

2. **Funciones principales** GRUPO: GALLARDO 
1. Gestión de Propietarios 
1. Gestión de Residentes y Miembros de Familia 
1. Gestión de Cuentas 
1. Autorización de visitas 

GRUPO: ORELLANA-RAMÍREZ 

5. Control de Acceso mediante QR 
6. Control de Acceso sin código QR 
6. OCR, Reconocimiento Facial y Validación de identidad 
6. Notificaciones 

**2.1 Características del usuario** 

El sistema será utilizado por los siguientes roles, cada uno con diferentes niveles de acceso y funcionalidades dentro de la urbanización. 



|**Rol / Tipo de usuario** |**Descripción** |**Requerimientos funcionales asociados** |
| :- | - | :- |
|**Administrador del sistema** |Usuario responsable de la gestión de propietarios y residentes, miembros de familia y accesos. |<p>RF-C05, RF-C06, RF-C07, RF-C08, RF-C09 </p><p>RF-P01, RF-P02, RF-P03, RF-P04, RF-P05 </p><p>RF-R01, RF-R02, RF-R03, RF-R04, RF-R05, RF-R06 RF-N01, RF-N02, RF-N03, RF-N04 </p>|
|**Propietario** |Usuario que puede registrar, actualizar o dar de baja a sus residentes autorizados, así como gestionar su propia información. ||
|**Residente** |Usuario que puede registrar a los miembros de su familia y actualizar sus datos personales. |RF-C01, RF-C04 RF-Q01, RF-Q02 |
|**Miembro de familia** |Usuario dependiente del residente, con funciones limitadas  |RF-C02, RF-C03,  RF-Q01, RF-Q02 |
|**Guardia de seguridad** |Usuario encargado del control de acceso y registro de visitantes. |RF-AQ02 |
|**Visitante** |Usuario que interactúa con el sistema para realizar el acceso a la urbanización |RF-AQ01,  |

3. **Requerimientos específicos** 
1. **Requerimientos funcionales** 
1. ***Listado general de requerimientos funcionales*** 

|Código |Nombre |Módulo / Categoría |Descripción breve |
| - | - | - | - |
|RF-AQ01 |Ingreso de Visita sin Código QR |Control de Accesos sin Código QR |Gestiona el ingreso de visitas sin uso de código QR. |
|RF-AQ02 |Autorización Manual de Visita por Guardia |Control de Accesos sin Código QR |Permite a un guardia autorizar manualmente el ingreso de una visita. |



|RF-AQ03 |Llamada Telefónica de Autorización al Residente |Control de Accesos sin Código QR |El sistema realiza una llamada telefónica automática al residente para solicitar la autorización de ingreso de una visita. |
| - | :- | :- | :- |
|RF-AQ04 |Ingreso de Visita Peatonal |Control de Accesos sin Código QR |Permite registrar el ingreso de una visita peatonal. |
|RF-AQ05 |Ingreso Automático de Residente Activo |Control de Accesos sin Código QR |Permite el ingreso automático de residentes activos. |
|RF-AQ06 |Salida Automática de Residente Activo |Control de Accesos sin Código QR |Permite la salida automática de residentes activos |
|RF-AQ07 |Salida de visitante |Control de Accesos sin Código QR |Permite registrar la salida de un visitante que ingresó en vehículo con o sin código QR. |
|RF-C01 |Crear Cuenta de Residente |Gestión de Cuentas |Permite crear la cuenta de aplicación para un residente. |
|RF-C02 |Crear Cuenta de Miembro de Familia no registrado |Gestión de Cuentas |Permite crear cuenta para miembro no registrado usando autorización del residente. |
|RF-C03 |Crear Cuenta de Miembro de Familia Registrado |Gestión de Cuentas |Permite crear cuenta para miembro ya registrado en el sistema. |
|RF-C04 |Autorización de Residente para Registro de Miembro de Familia |Gestión de Cuentas |Permite que el residente apruebe o rechace solicitudes de registro de miembros de familia. |
|RF-C05 |Bloquear Cuenta de Residente y Miembros de Familia |Gestión de Cuentas |Permite bloquear las cuentas de un residente y todos sus miembros de familia. |
|RF-C06 |Desbloquear Cuenta de Residente y Miembros de Familia |Gestión de Cuentas |Permite desbloquear las cuentas de un residente y sus miembros de familia. |
|RF-C07 |<p>Bloquear Cuenta Individual (Residente </p><p>o Miembro de Familia) </p>|Gestión de Cuentas |Permite bloquear una cuenta específica de residente o miembro. |
|RF-C08 |<p>Desbloquear Cuenta Individual (Residente </p><p>o Miembro de Familia) </p>|Gestión de Cuentas |Permite desbloquear una cuenta específica de residente o miembro. |
|RF-C09 |Eliminación Definitiva de Cuenta |Gestión de Cuentas |Permite eliminar de forma irreversible una cuenta de aplicación. |
|RF-N01 |Notificaciones Masivas Push a Residentes |Notificaciones |Permite enviar un mensaje push masivo a todos los residentes activos. |



|RF-N02 |Notificaciones Masivas Push a Propietarios |Notificaciones |Permite enviar un mensaje push masivo a todos los propietarios activos. |
| - | :- | - | :- |
|RF-N03 |Notificación Individual a Residente |Notificaciones |Permite enviar una notificación push individual a un residente activo. |
|RF-N04 |Notificación Individual a Propietario |Notificaciones |Permite enviar una notificación push individual a un propietario activo. |
|RF-OB01 |Validación Biométrica de Rostro |OCR, Reconocimiento Facial y Validación de identidad |Permite validar la identidad de un usuario mediante una captura en vivo de su rostro. |
|RF-OB02 |Aplicación de OCR al Documento de Identidad |OCR, Reconocimiento Facial y Validación de identidad |Permite extraer los datos personales mediante la aplicación de OCR sobre una imagen del documento de identidad |
|RF-P01 |Registro de Propietario |Gestión de Propietarios |Permite registrar los datos de un propietario de vivienda. |
|RF-P02 |Registro de Cónyuge |Gestión de Propietarios |Permite registrar al cónyuge asociado a un propietario. |
|RF-P03 |Actualización de información del propietario |Gestión de Propietarios |Permite modificar datos de contacto del propietario. |
|RF-P04 |Baja de propietario |Gestión de Propietarios |Permite desactivar a un propietario de una vivienda. |
|RF-P05 |Cambio de Propietario de Vivienda |Gestión de Propietarios |Gestiona el cambio de propietario de una vivienda. |
|RF-Q01 |Generar Código QR propio |Control de Accesos con Código QR |Permite al residente generar su propio código QR de acceso. |
|RF-Q02 |Generar Código QR para Visita (Residente o Miembro de Familia) |Control de Accesos con Código QR |Permite generar un código QR para visitas autorizadas. |
|RF-R01 |Registro de Residente |Gestión de Residentes y Miembros de Familia |Permite registrar a un residente asociado a una vivienda. |
|RF-R02 |Registro de Miembro de Familia |Gestión de Residentes y Miembros de Familia |Permite registrar miembros de familia de un residente. |
|RF-R03 |Desactivación de Residente |Gestión de Residentes y Miembros de Familia |Permite desactivar temporalmente a un residente. |
|RF-R04 |Desactivación de Miembro de Familia |Gestión de Residentes y Miembros de Familia |Permite desactivar temporalmente a un miembro de familia. |



|RF-R05 |Reactivación de Residente |Gestión de Residentes y Miembros de Familia |Permite reactivar a un residente previamente desactivado. |
| - | :- | :- | - |
|RF-R06 |Reactivación de Miembro de Familia |Gestión de Residentes y Miembros de Familia |Permite reactivar a un miembro de familia previamente desactivado. |

2. ***Detalle de los requerimientos funcionales*** 
1. ***Gestión de Propietarios*** 

**Requerimiento Funcional RF-P01 – Registro de Propietario** 



|**ID** |RF-P01 |
| - | - |
|**Nombre** |Registro de Propietario |
|**Descripción** |El sistema permite registrar a un propietario, validando datos personales, documento de propiedad y una lista de fotografías de rostro destinadas a futuras validaciones faciales. |
|**Entradas** |<p>- Identificación (cédula o RUC válido si nacionalidad = Ecuador) </p><p>- Nacionalidad (lista de selección, por defecto “Ecuador”) </p><p>- Nombres </p><p>- Apellidos </p><p>- Fecha de nacimiento </p><p>- Correo electrónico </p><p>- Celular </p><p>- Manzana </p><p>- Villa </p><p>- Dirección alternativa (opcional) </p><p>- Documento de propiedad en PDF válido y no vacío </p><p>- Lista de fotografías de rostro (mínimo 2 imágenes JPG/PNG, no vacías y de distintas resoluciones) </p><p>- Estado (activo/inactivo) </p><p>- Tipo (propietario/residente/miembro; por defecto residente) </p>|
|**Procesamiento** |<p>1. Validar identificación: cédula/RUC válido si es ecuatoriano. </p><p>2. Validar nombres y apellidos no vacíos. </p><p>3. Validar fecha de nacimiento (mayor de 18 años y no futura). </p><p>4. Validar correo electrónico. </p><p>5. Validar celular ecuatoriano: 09XXXXXXXX. </p><p>6. Validar manzana y villa existentes. </p><p>7. Validar documento de propiedad PDF no vacío. </p><p>8. Validar lista de fotografías: JPG/PNG, no vacías, distintas resoluciones. </p><p>9. Registrar datos del propietario. </p><p>10. Establecer estado=activo, tipo=residente. </p><p>11. Registrar fecha y hora del registro. </p><p>12. Mostrar mensaje de confirmación o error. </p>|
|**Salidas** |<p>- “Registro ingresado correctamente.” </p><p>- “Error: [detalle del campo inválido].” </p>|
|**Prioridad** |Alta |
|**Restricciones / Reglas de negocio** |<p>1. Solo puede existir un propietario activo por vivienda. </p><p>2. Todo propietario será asignado de tipo residente por defecto. </p><p>3. El estado inicial será activo. </p><p>4. Propietarios ecuatorianos deben registrar cédula o RUC válidos. </p><p>5. Documento de propiedad debe ser PDF válido y no vacío. </p>|



||<p>6. Celular ecuatoriano debe cumplir formato 09XXXXXXXX. </p><p>7. Lista de fotografías de rostro obligatoria con requisitos de calidad. </p><p>8. Cada imagen de la lista de fotografías debe tener distinta resolución, sin obstrucciones (norma interna del sistema de validación facial). </p>|
| :- | - |
|**Dependencias** ||
|**Criterios de aceptación (Dado– Cuando– Entonces)** |<p>Escenario 1 – Registro exitoso </p><p>Dado un propietario con todos los datos válidos, Cuando ingresa la información completa, Entonces el sistema registra al propietario. </p><p>Escenario 10 – Manzana y villa con propietario  </p><p>Dado una manzana y villa asociadas a un propietario registrado.** </p><p>Cuando el usuario intenta guardar el registro, </p><p>Entonces el sistema muestra 'Error: la vivienda [detalle de manzana y villa] ya tiene un propietario registrado.’ y no guarda el registro. </p><p>Escenario adicional – Aplicación de criterios de validación comunes </p><p>Dado que este requisito está sujeto a criterios de validación transversales, Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-01, CV-03, CV-04, CV- 05, CV-06, CV-07, CV-08, CV-09, CV-15 </p>|
|**Fuente / Justificación** |Entrevista con el cliente |

**Requerimiento Funcional RF-P02 – Registro de Cónyuge** 



|**ID** |RF-P02 |
| - | - |
|**Nombre** |**Registro de cónyuge** |
|**Descripción** |El sistema permite registrar el cónyuge asociado a un propietario existente dentro de la urbanización. |
|**Entradas** |Identificación del propietario, identificación, nombres, apellidos, fecha de nacimiento, correo electrónico, celular, manzana, villa, lista de fotografías de rostro, dirección alternativa (opcional), estado (activo/inactivo), tipo (propietario/residente/miembro). |
|**Procesamiento** |<p>1. Validar el formato de los campos. </p><p>2. Confirmar que el ID del propietario exista y esté activo. </p><p>3. Confirmar que la manzana y la villa correspondan a la misma vivienda del propietario. </p><p>4. Validar que la fotografía de rostro sea un archivo de imagen (JPG/PNG) no vacío y con buena calidad para futuras validaciones faciales. </p><p>5. Registrar los datos del cónyuge en la base de datos. </p><p>6. Generar mensaje de confirmación o error. </p>|
|**Salidas** |Mensaje “Registro de cónyuge ingresado correctamente” o “Error: [detalle del campo inválido]”. |
|**Prioridad** |Alta |
|**Restricciones / Reglas de negocio** |<p>1. Cada propietario solo puede tener un cónyuge registrado. </p><p>2. El cónyuge se considera miembro de familia por defecto. </p><p>3. El registro del cónyuge requiere un propietario válido previamente registrado. </p><p>4. La fotografía de rostro es obligatoria. </p>|



||<p>5\.  Debe ser una imagen nítida, sin obstrucciones (norma interna del </p><p>sistema de validación facial). </p>|
| :- | - |
|**Dependencias** |RF-01 (Registro de propietario). |
|**Criterios de aceptación (formato Dado–Cuando– Entonces)** |<p>Escenario 1 – Registro exitoso </p><p>Dado un propietario válido y un cónyuge con datos correctos, Cuando el usuario selecciona “Guardar cónyuge”, </p><p>Entonces el sistema registra los datos y muestra “Registro de cónyuge ingresado correctamente”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-01, CV-05, CV- 06, CV-09, CV-15, CV-16, CV-17 </p>|
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-P03 – Actualización de información del propietario** 



|**ID** |RF-P03 |
| - | - |
|**Nombre** |**Actualización de información del propietario** |
|**Descripción** |El sistema permite actualizar los datos de contacto del propietario (correo electrónico, lista de fotografías de rostro y número de celular) una vez que este se encuentre registrado en el sistema. |
|**Entradas** |Identificación del propietario, nuevo correo electrónico, nuevo número de celular. |
|**Procesamiento** |<p>1. Validar el formato de los campos ingresados. </p><p>2. Verificar que la identificación corresponda a un propietario existente y activo en el sistema. </p><p>3. Actualizar los campos de correo electrónico, lista de fotografías de rostro y celular con los nuevos valores ingresados. </p><p>4. Generar mensaje de confirmación o error. </p>|
|**Salidas** |Mensaje “Datos del propietario actualizados correctamente” o “Error: [detalle del campo inválido o propietario no encontrado]”. |
|**Prioridad** |Media |
|**Restricciones / Reglas de negocio** |<p>1. Solo se permite la actualización de correo electrónico, lista de fotografías de rostro y celular. </p><p>2. La identificación del propietario debe existir previamente en el sistema. </p><p>3. Las fotografías de rostro deben ser archivos de imagen (JPG/PNG) no vacíos y de distintas calidad (resolución) para futuras validaciones faciales. </p><p>4. No se permite modificar datos de identificación (identificación, manzana, villa, nombres o apellidos). </p>|
|**Dependencias** |RF-P01 |



|**Criterios de aceptación (formato Dado–Cuando– Entonces)** |<p>Escenario 1 – Actualización exitosa </p><p>Dado un propietario existente identificado por su identificación y con datos válidos, </p><p>Cuando el usuario ingresa un nuevo correo electrónico y/o número de celular válidos y selecciona la opción “Actualizar información”, </p><p>Entonces el sistema guarda los nuevos datos y muestra el mensaje “Datos del propietario actualizados correctamente”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-05, CV-06, CV- 09, CV-10 </p>|
| :- | - |
|**Fuente / Justificación** |Entrevista con el cliente- |

**Requerimiento Funcional RF-P04 – Baja de propietario** 



|**ID** |RF-P04 |
| - | - |
|**Nombre** |**Baja de propietario** |
|**Descripción** |El sistema permite dar de baja a un propietario registrado en la urbanización, cambiando su estado a “inactivo”. |
|**Entradas** |Identificación del propietario, motivo de baja. |
|**Procesamiento** |<p>1. Validar que la identificación corresponda a un propietario existente y activo. </p><p>2. Registrar el motivo de baja en el historial del sistema. </p><p>3. Cambiar el campo estado a “inactivo”. </p><p>4. Generar mensaje de confirmación o error. </p>|
|**Salidas** |Mensaje “Propietario dado de baja correctamente” o “Error: [detalle del campo inválido o propietario no encontrado]”. |
|**Prioridad** |Alta |
|**Restricciones / Reglas de negocio** |<p>1. Solo puede darse de baja a propietarios activos. </p><p>2. El campo motivo de baja es obligatorio. </p><p>3. El/la cónyuge también será dado de baja. </p><p>4. La baja no elimina los registros históricos del propietario, solo cambia su estado. </p>|
|**Dependencias** |RF-P01 |
|**Criterios de aceptación (formato Dado–Cuando– Entonces)** |<p>Escenario 1 – Baja exitosa </p><p>Dado un propietario existente con identificación válida y estado activo, Cuando el usuario ingresa el motivo de baja y selecciona la opción “Dar de baja propietario”, </p><p>Entonces el sistema cambia los campos estado y residente a “inactivo” y muestra el mensaje “Propietario dado de baja correctamente”. </p>|



||<p>Escenario 2 – Motivo de baja no ingresado </p><p>Dado un propietario válido pero sin que se haya ingresado el motivo de baja, </p><p>Cuando el usuario intenta ejecutar la operación, </p><p>Entonces el sistema muestra “Error: el motivo de baja es obligatorio” y no guarda los cambios. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-14 </p>|
| :- | - |
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-P05 – Cambio de Propietario de Vivienda** 



|ID |RF-P05 |
| - | - |
|Nombre |Cambio de Propietario de Vivienda |
|Descripción |El sistema permite realizar el cambio completo de propietario de una vivienda. Se desactiva al propietario actual, se registra o activa al nuevo propietario y se actualiza la relación con el residente principal. Si el residente actual es el mismo propietario, el nuevo propietario será registrado automáticamente como residente activo de la vivienda. |
|Entradas |<p>- Manzana </p><p>- Villa </p><p>- Razón del cambio de propietario </p>|
|Procesamiento |<p>1. El usuario ingresa la manzana y villa. </p><p>2. El sistema valida que la vivienda exista. </p><p>3. Se valida que el propietario esté activo. </p><p>4. Se obtiene al propietario actual. </p><p>5. Se muestran los datos del propietario para confirmación. </p><p>6. El usuario ingresa la razón del cambio. </p><p>7. El sistema desactiva al propietario actual. </p><p>8. Se solicitan y validan los datos del nuevo propietario. </p><p>9. El sistema registra o activa al nuevo propietario. </p><p>10. Se actualiza la propiedad de la vivienda. </p><p>11. Se actualiza la relación con el residente principal. </p><p>12. Si el residente actual es el mismo propietario, el nuevo propietario se registra como residente activo. </p><p>13. El sistema registra la auditoría. </p><p>14. El sistema muestra mensaje de confirmación. </p>|
|Salidas |<p>- “Cambio de propietario realizado correctamente.” </p><p>- “Error: la vivienda no existe.” </p><p>- “Error: el nuevo propietario no cumple las validaciones requeridas.” </p>|
|Prioridad |Alta |



|Restricciones / Reglas de negocio |<p>1. Una vivienda solo puede tener un propietario activo. </p><p>2. El propietario anterior debe estar activo.  </p><p>3. El propietario anterior debe quedar inactivo. </p><p>4. El nuevo propietario debe cumplir todas las validaciones requeridas. </p><p>5. La reasociación del residente principal es obligatoria si existe. </p><p>6. Los miembros de familia no se modifican automáticamente. </p><p>7. El cambio debe registrarse en la bitácora. </p><p>8. Si el residente actual de la vivienda es el mismo propietario, el nuevo propietario será registrado automáticamente como residente activo. </p>|
| :- | - |
|Dependencias |RF-P01, RF-P04, RF-R01 |
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Cambio exitoso de propietario </p><p>Dado una vivienda con propietario activo, </p><p>Cuando se ingresa manzana, villa y motivo y los datos del nuevo propietario son válidos, </p><p>Entonces se realiza el cambio correctamente. </p><p>Escenario 2 – Nuevo propietario inválido </p><p>Dado que los datos del nuevo propietario no cumplen las validaciones, </p><p>Cuando se intenta registrar, </p><p>Entonces se muestra “Error: el nuevo propietario no cumple las validaciones requeridas”. </p><p>Escenario 3 – Actualización residente–propietario </p><p>Dado que el propietario ha sido cambiado, </p><p>Cuando el sistema actualiza la vivienda, </p><p>Entonces el residente queda asociado al nuevo propietario sin alterar su estado. </p><p>Escenario 4 – Nuevo propietario se convierte en residente automáticamente </p><p>Dado una vivienda cuyo residente actual es el propietario, Cuando se realiza el cambio de propietario, </p><p>Entonces el sistema registra al nuevo propietario como residente activo y muestra el mensaje “Nuevo propietario asignado como residente de la vivienda”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-07 </p>|

2. ***Gestión de Residentes y Miembros de Familia*** 

Cambio de propietario de vivienda -> asocia un nuevo propietario a la vivienda y el anterior es dado de baja. -> dar de baja al actual propietario, dar de alta al nuevo propietario y actualizar propietario asociado al residente 

**Requerimiento Funcional RF-R01 – Registro de Residente** 



|**ID** |RF-R01 |
| - | - |
|**Nombre** |**Registro de residente** |
|**Descripción** |El sistema permite registrar a un residente asociado a una vivienda dentro de la urbanización, siempre que cuente con la autorización del propietario. |
|**Entradas** |Identificación, nombres, apellidos, fecha de nacimiento, correo electrónico, celular, manzana, villa, fotografía de rostro, nie- propietario, documento de autorización de residencia emitido por el propietario, estado (activo), tipo (propietario/residente/miembro). |
|**Procesamiento** |<p>1. Validar el formato de los campos ingresados. </p><p>2. Confirmar que la manzana y la villa existan en el sistema. </p><p>3. Verificar que exista una autorización de residencia válida otorgada por un propietario registrado. </p><p>4. Validar que la fotografía de rostro sea un archivo de imagen (JPG/PNG) no vacío y con buena calidad para futuras validaciones faciales. </p><p>5. Registrar los datos del residente en la base de datos con los campos estado y residente en “activo”. </p><p>6. Generar mensaje de confirmación o error. </p>|
|**Salidas** |Mensaje “Residente registrado correctamente” o “Error: [detalle del campo inválido o autorización no válida]”. |
|**Prioridad** |Alta |
|**Restricciones / Reglas de negocio** |<p>1. Cada residente debe estar vinculado a un propietario mediante una autorización válida. </p><p>2. El documento de autorización debe ser un archivo PDF no vacío. </p><p>3. No se permite registrar dos residentes con la misma identificación. </p><p>4. No se permite registrar dos residentes en una misma manzana y villa. </p><p>5. Los campos estado y residente se inicializan automáticamente en “activo”. </p>|
|**Dependencias** |RF-01 (Registro de propietario) |
|**Criterios de aceptación (formato Dado–Cuando– Entonces)** |<p>Escenario 1 – Registro exitoso </p><p>Dado un residente con datos válidos y autorización de residencia emitida por un propietario, </p><p>Cuando el usuario selecciona “Guardar residente”, </p><p>Entonces el sistema guarda el registro y muestra el mensaje “Residente registrado correctamente”. </p><p>Escenario 2 – Autorización ausente o inválida </p><p>Dado un residente que no adjunta documento de autorización o lo carga en formato distinto a PDF, </p><p>Cuando el usuario intenta guardar el registro, </p><p>Entonces el sistema muestra “Error: el documento de autorización debe ser un archivo PDF válido y no vacío” y no guarda la información. </p>|



||<p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-04, CV-05, CV-06, CV-07, CV-09, CV-10, CV-13, CV-14, CV-18 </p>|
| :- | :- |
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-R02 – Registro de Miembro de Familia** 



|ID |RF-R02 |
| - | - |
|Nombre |Registro de miembro de familia |
|Descripción |El sistema permite registrar un miembro de familia asociado a un residente activo previamente registrado. Se validan los datos esenciales del miembro de familia y la asociación correcta a la vivienda del residente. |
|Entradas |<p>- Identificación del miembro de familia </p><p>- Identificación del residente </p><p>- Manzana y villa </p><p>- Nombres </p><p>- Apellidos </p><p>- Correo electrónico </p><p>- Fecha de nacimiento </p><p>- Celular </p><p>- Fotografía del rostro </p>|
|Procesamiento |<p>1. El usuario ingresa la identificación del miembro de familia y la identificación del residente. </p><p>2. El sistema verifica que el residente exista, que esté activo y que la manzana y villa coincidan con su vivienda. </p><p>3. Si el residente existe, el sistema solicita los datos del miembro de familia. </p><p>4. El sistema valida el formato de todos los datos. </p><p>5. El sistema registra al miembro de familia asociado al residente. </p><p>6. El sistema muestra un mensaje de confirmación. </p>|
|Salidas |Mensaje “Miembro de familia registrado correctamente” o “Error: [detalle del campo inválido o autorización no válida]”. |
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El miembro de familia debe pertenecer a la misma manzana y villa que el residente. </p><p>2. El residente debe estar activo. </p><p>3. La fecha de nacimiento no puede ser futura. </p><p>4. La fotografía del rostro es obligatoria. </p><p>5. Solo se pueden registrar miembros para residentes activos. </p>|
|Dependencias |RF-05 (Registro de residente) |
|Criterios de aceptación |Escenario 1 – Registro exitoso Dado un residente existente, |



|(Dado–Cuando– Entonces) |<p>Cuando se ingresan todos los datos válidos, </p><p>Entonces el sistema registra al miembro de familia exitosamente. </p><p>Escenario 2 – Fotografía no capturada </p><p>Dado ausencia de fotografía, </p><p>Cuando se intenta registrar, </p><p>Entonces el sistema muestra “Error: la fotografía de rostro es obligatoria”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-13, CV-14, CV-17 </p>|
| :- | - |

**Requerimiento Funcional RF-R03 – Desactivación de Residente** 



|ID |RF-R03 |
| - | - |
|Nombre |Desactivación de Residente |
|Descripción |El sistema permite desactivar temporalmente a un residente, cambiando su estado y condición de residencia a 'inactivo'. La acción es reversible mediante un proceso de reactivación. |
|Entradas |<p>- Identificación del residente </p><p>- Motivo de desactivación </p>|
|Procesamiento |<p>1. Validar que la identificación corresponda a un residente existente. </p><p>2. Mostrar los datos para confirmar la identidad. </p><p>3. Registrar motivo de desactivación. </p><p>4. Cambiar estado y condición de residencia a 'inactivo'. </p><p>5. Desactivar automáticamente todas las cuentas asociadas de miembros de familia vinculados a esa vivienda. </p><p>6. Registrar fecha, hora y motivo. </p><p>7. Mostrar mensaje de confirmación. </p>|
|Salidas |• “Residente desactivado correctamente.” |
|Prioridad |Alta |
|Restricciones |<p>1. La cuenta desactivada puede reactivarse. </p><p>2. Un residente inactivo no puede iniciar sesión. </p><p>3. La acción no implica eliminación permanente. </p><p>4. Cuando un residente es desactivado, todos los miembros de familia asociados a la vivienda también serán desactivados automáticamente. </p><p>5. Los miembros de familia inactivos tampoco podrán iniciar sesión hasta que el residente sea reactivado. </p>|
|Dependencias |RF-R01, RF-R02 |
|Criterios de aceptación |<p>Escenario 1 – Desactivación exitosa </p><p>Dado un residente activo existente, </p><p>Cuando el usuario ingresa la identificación y motivo, Entonces el sistema cambia su estado a inactivo y desactiva </p>|



||<p>automáticamente a todos sus miembros de familia. </p><p>Escenario 4 – Desactivación de miembros de familia asociada Dado un residente con miembros de familia activos asociados, Cuando su cuenta es desactivada, </p><p>Entonces el sistema marca a todos los miembros de familia como “inactivos” también. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-14 </p>|
| :- | - |

**Requerimiento Funcional RF-R04 – Desactivación de Miembro de Familia** 



|ID |RF-R04 |
| - | - |
|Nombre |Desactivación de Miembro de Familia |
|Descripción |El sistema permite desactivar temporalmente a un miembro de familia, cambiando su estado a 'inactivo'. La acción es reversible mediante reactivación. |
|Entradas |<p>- Identificación del miembro de familia </p><p>- Motivo de desactivación </p>|
|Procesamiento |<p>1. Validar que la identificación corresponda a un miembro de familia existente. </p><p>2. Mostrar los datos para confirmar la identidad. </p><p>3. Registrar el motivo de desactivación. </p><p>4. Cambiar estado a 'inactivo'. </p><p>5. Registrar fecha, hora y motivo. </p><p>6. Mostrar mensaje de confirmación. </p>|
|Salidas |• “Miembro de familia desactivado correctamente.” |
|Prioridad |Alta |
|Restricciones |<p>1. La desactivación es reversible. </p><p>2. Un miembro de familia inactivo no puede iniciar sesión. </p><p>3. No se elimina información del sistema. </p>|
|Dependencias |RF-R02 |
|Criterios de aceptación |<p>Escenario 1 – Desactivación exitosa </p><p>Dado un miembro de familia activo, </p><p>Cuando se ingresa la identificación y motivo, Entonces el sistema cambia su estado a inactivo. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-14 </p>|

**Requerimiento Funcional RF-R05 – Reactivación de Residente** 



|ID |RF-R05 |
| - | - |
|Nombre |Reactivación de Residente |
|Descripción |El sistema permite reactivar a un residente previamente desactivado. La reactivación restablece su estado y condición de residencia a 'activo'. Esta acción no modifica el estado de los miembros de familia asociados. |
|Entradas |<p>- Identificación del residente </p><p>- Motivo de reactivación </p>|
|Procesamiento |<p>1. El usuario ingresa la identificación del residente. </p><p>2. El sistema valida que el residente exista en la base de datos. </p><p>3. El sistema verifica que el residente se encuentre en estado inactivo. </p><p>4. El sistema muestra los datos del residente para confirmar su identidad. </p><p>5. El usuario ingresa el motivo de reactivación. </p><p>6. El sistema cambia el campo estado a 'activo'. </p><p>7. Se registra fecha, hora y motivo de la reactivación. </p><p>8. El sistema muestra mensaje de confirmación. </p>|
|Salidas |<p>- “Residente reactivado correctamente.” </p><p>- “Error: residente no existe.” </p><p>- “Error: el residente ya está activo.” </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo se puede reactivar a residentes con estado inactivo. </p><p>2. La reactivación no afecta el estado de los miembros de familia. </p><p>3. Un residente reactivado puede volver a iniciar sesión. </p><p>4. Toda reactivación debe registrarse en la auditoría del sistema. </p>|
|Dependencias |RF-R03 |
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Reactivación exitosa </p><p>Dado un residente existente en estado inactivo, </p><p>Cuando el usuario ingresa la identificación y el motivo, </p><p>Entonces el sistema cambia su estado a activo y muestra “Residente reactivado correctamente”. </p><p>Escenario 3 – Residente ya activo </p><p>Dado un residente en estado activo, </p><p>Cuando se intenta reactivarlo nuevamente, </p><p>Entonces el sistema muestra “Error: el residente ya está activo”. </p><p>Escenario 4 – Reactivación no afecta a miembros de familia Dado un residente con miembros de familia inactivos, Cuando el residente es reactivado, </p><p>Entonces el estado de los miembros de familia permanece sin cambios. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10 </p>|

**Requerimiento Funcional RF-R06 – Reactivación de Miembro de Familia** 



|ID |RF-R06 |
| - | - |
|Nombre |Reactivación de Miembro de Familia |
|Descripción |El sistema permite reactivar a un miembro de familia previamente desactivado. La reactivación restablece su estado y condición de residencia a 'activo', siempre que el residente principal asociado se encuentre activo. |
|Entradas |<p>- Identificación del miembro de familia </p><p>- Motivo de reactivación </p>|
|Procesamiento |<p>1. El usuario ingresa la identificación del miembro de familia. </p><p>2. El sistema valida que el miembro exista en la base de datos. </p><p>3. El sistema verifica que el miembro se encuentre en estado inactivo. </p><p>4. El sistema identifica al residente principal asociado. </p><p>5. El sistema valida que el residente esté activo. </p><p>6. El sistema muestra los datos del miembro para confirmar identidad. </p><p>7. El usuario ingresa el motivo de reactivación. </p><p>8. El sistema cambia los campos estado y residente a 'activo'. </p><p>9. El sistema registra fecha, hora y motivo de reactivación. </p><p>10. El sistema muestra mensaje de confirmación. </p>|
|Salidas |<p>- “Miembro de familia reactivado correctamente.” </p><p>- “Error: miembro de familia no existe.” </p><p>- “Error: el miembro de familia ya está activo.” </p><p>- “Error: el residente asociado está inactivo. No se puede reactivar al miembro de familia.” </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo se pueden reactivar miembros en estado inactivo. </p><p>2. El residente asociado debe estar activo para permitir la reactivación. </p><p>3. La reactivación no cambia el estado del residente. </p><p>4. Toda reactivación debe registrarse en la bitácora del sistema. </p>|
|Dependencias |RF-R04 |
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Reactivación exitosa </p><p>Dado un miembro de familia inactivo y un residente asociado activo, Cuando el usuario ingresa la identificación y el motivo, </p><p>Entonces el sistema cambia su estado a activo y muestra “Miembro de familia reactivado correctamente”. </p><p>Escenario 2 – Miembro no existe </p><p>Dado una identificación no registrada, </p><p>Cuando se intenta reactivar al miembro de familia, </p><p>Entonces el sistema muestra “Error: miembro de familia no existe”. </p><p>Escenario 3 – Miembro ya activo Dado un miembro en estado activo, </p>|



||<p>Cuando se intenta reactivarlo nuevamente, </p><p>Entonces el sistema muestra “Error: el miembro de familia ya está activo”. </p><p>Escenario 4 – Residente asociado inactivo </p><p>Dado un miembro inactivo y un residente asociado inactivo, Cuando se intenta reactivarlo, </p><p>Entonces el sistema muestra “Error: el residente asociado está inactivo. No se puede reactivar al miembro de familia”. </p>|
| :- | - |

3. ***Gestión de Cuentas*** 

**Requerimiento Funcional RF-C01 – Crear Cuenta de Residente** 



|ID |RF-C01 |
| - | - |
|Nombre |Crear cuenta de residente |
|Descripción |El sistema permite que un residente cree una cuenta de acceso a la aplicación, validando su identidad mediante autorización del propietario y reconocimiento facial. |
|Entradas |Identificación del residente, fotografía de rostro, usuario, contraseña, confirmación de contraseña. |
|Procesamiento |<p>1. Validar que la identificación corresponda a un residente registrado activo. </p><p>2. Solicitar reconocimiento facial. </p><p>3. Validar coincidencia entre la fotografía de rostro y la registrada. </p><p>4. Solicitar usuario, contraseña y confirmación de contraseña. </p><p>5. Validar que la contraseña cumple la política de seguridad. </p><p>6. Validar que la contraseña y su confirmación coincidan. </p><p>7. Crear la cuenta del residente. </p><p>8. Generar mensaje de confirmación o error. </p>|
|Salidas |“Cuenta creada exitosamente” o “Error: [detalle de validación incorrecta]”. |
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. La identificación debe pertenecer a un residente registrado activo. </p><p>2. La autorización fue ingresada al momento del registro del residente en el sistema. </p><p>3. El reconocimiento facial debe coincidir con la fotografía almacenada. </p><p>4. La contraseña debe ingresarse dos veces y ambas deben coincidir. </p><p>5. La contraseña debe cumplir políticas de seguridad. </p><p>6. Cada residente solo puede crear una cuenta. </p>|
|Dependencias |RF-05 (Registro de residente), RF-01 (Registro de propietario). |
|Criterios de aceptación |Escenario 1 – Identificación válida Dado un residente registrado, |



|(formato Dado– Cuando– Entonces) |<p>Cuando ingresa su identificación, </p><p>Entonces el sistema solicita el código de autorización. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-13, CV14, CV-19, CV-20, CV-21, CV-22, CV-23, CV-24, CV-25 </p>|
| :- | - |
|Fuente / Justificación |Entrevista con el cliente. |

**Requerimiento Funcional RF-C02 – Crear Cuenta de Miembro de Familia no registrado** 



|ID |RF-C02 |
| - | - |
|Nombre |Crear cuenta de miembro de familia |
|Descripción |El sistema permite crear una cuenta para un miembro de familia que aún no ha sido registrado previamente. El proceso valida la relación con el residente, verifica unicidad del parentesco, solicita autorización y ejecuta validaciones biométricas antes de crear la cuenta. |
|Entradas |<p>- Identificación del miembro de familia </p><p>- Identificación del residente </p><p>- Manzana </p><p>- Villa </p><p>- Código de autorización del residente </p><p>- Nombres </p><p>- Apellidos </p><p>- Correo electrónico </p><p>- Fecha de nacimiento </p><p>- Celular </p><p>- Usuario </p><p>- Contraseña  </p><p>- Confirmación de contraseña </p><p>- Parentesco (esposo/a, padre, madre, hijo/a, otro – especificar) </p><p>- Captura facial en vivo </p>|
|Procesamiento |<p>1. Validar que la identificación del residente exista y esté activa. </p><p>2. Validar que la manzana y villa correspondan a la vivienda del residente. </p><p>3. Solicitar datos personales y credenciales del miembro de familia. </p><p>4. Enviar solicitud de código de autorización al residente. </p><p>5. Validar el código ingresado. </p><p>6. Solicitar y validar el parentesco seleccionado. </p><p>7. Validar unicidad según parentesco: </p><p>- Solo un esposo/a por vivienda. </p><p>- Solo un padre. </p><p>- Solo una madre. </p><p>- Múltiples hijos/as permitidos. </p><p>- 'Otro' requiere descripción. </p><p>8. Validar que la contraseña coincida con la confirmación. </p>|



||<p>9. Solicitar captura facial en vivo y validar rostro. </p><p>10. Registrar la cuenta del miembro de familia. </p><p>11. Mostrar mensaje de éxito o error. </p>|
| :- | - |
|Salidas |“Cuenta creada exitosamente” o “Error: [detalle del campo inválido]”. |
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El parentesco es obligatorio. </p><p>2. Solo puede existir un esposo/a por vivienda. </p><p>3. Solo puede existir un padre por vivienda. </p><p>4. Solo puede existir una madre por vivienda. </p><p>5. Se permiten varios hijos/as. </p><p>6. Parentesco 'otro' debe incluir descripción. </p><p>7. La captura facial es obligatoria. </p><p>8. Las credenciales deben cumplir políticas de seguridad. </p>|
|Dependencias |RF-04 (Registro de residente), RF-06 (Registro de miembro de familia), RF-07 (Crear cuenta residente), RF Autorización de residente |
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Creación exitosa </p><p>Dado que el miembro de familia no está registrado y el parentesco es válido, </p><p>Cuando ingresa todos los datos correctos y autorización del residente, Entonces el sistema crea la cuenta correctamente. </p><p>Escenario 2 – Parentesco duplicado </p><p>Dado que ya existe un registro activo para el parentesco </p><p>{esposo | esposa | padre | madre} en la vivienda, </p><p>Cuando el usuario intenta registrarse con ese mismo parentesco, Entonces el sistema muestra </p><p>“Error: ya existe un {esposo | esposa | padre | madre} registrado para esta vivienda” </p><p>y no guarda el registro. </p><p>Escenario 3 – Parentesco permitido (hijo/a) Dado que existen hijos registrados, </p><p>Cuando un usuario se registra como hijo/a, Entonces el sistema permite el registro. </p><p>Escenario 4 – Parentesco 'otro' sin descripción </p><p>Dado que el usuario selecciona 'otro' como parentesco, </p><p>Cuando intenta continuar sin especificar la descripción, </p><p>Entonces el sistema muestra “Error: debe especificar el parentesco”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-13, CV-14, CV-18, CV-20, CV-22, CV-25 </p>|
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-C03 – Crear Cuenta de Miembro de Familia Registrado** 



|ID |RF-C03 |
| - | - |
|Nombre |Crear Cuenta de Miembro de Familia Registrado |
|Descripción |El sistema permite crear una cuenta para un miembro de familia que ya fue previamente registrado por un residente activo. El sistema valida la identidad mediante el reconocimiento facial comparando la captura en vivo con la fotografía almacenada. |
|Entradas |<p>- Identificación del miembro de familia registrado </p><p>- Fotografía del rostro (captura en vivo) </p><p>- Contraseña </p><p>- Confirmación de contraseña </p>|
|Procesamiento |<p>1. El usuario ingresa su identificación. </p><p>2. El sistema valida que el miembro de familia exista, esté registrado, no tenga cuenta previa y el residente esté activo. </p><p>3. El sistema solicita una captura en vivo del rostro. </p><p>4. Se compara la captura con la foto almacenada. Si coincide, se solicita contraseña y confirmación. </p><p>5. El sistema verifica coincidencia de contraseñas. </p><p>6. Si todo es correcto, se crea la cuenta. </p><p>7. El sistema muestra un mensaje de confirmación. </p>|
|Salidas |<p>- “Cuenta creada correctamente.” </p><p>- “Error: el usuario no está registrado como miembro de familia.” </p><p>- “Error: validación facial fallida.” </p><p>- “Error: las contraseñas no coinciden.” </p><p>- “Error: la cuenta ya existe.” </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El miembro de familia debe existir y estar registrado previamente. </p><p>2. La validación facial debe coincidir. </p><p>3. Lass contraseñas deben coincidir. </p><p>4. Solo puede existir una cuenta por miembro de familia. </p>|
|Dependencias |RF-R02 |



|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Creación exitosa </p><p>Dado que el usuario es miembro de familia registrado, </p><p>Cuando ingresa su identificación, coincide la validación facial y las contraseñas coinciden, </p><p>Entonces el sistema crea la cuenta correctamente. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-20, </p><p>CV-21, CV-22, CV-23, CV-26 </p>|
| :- | - |

**Requerimiento Funcional RF-C04 – Autorización de residente para registro de miembro de familia** 



|ID |RF-C04 |
| - | - |
|Nombre |Autorización de residente para registro de miembro de familia |
|Descripción |El sistema permite que un residente apruebe o rechace una solicitud de registro iniciada por un miembro de familia no registrado. La aprobación genera un código único, de un solo uso y con una vigencia de 5 minutos, que habilita la continuación del proceso de registro. |
|Entradas |<p>- Identificación del residente </p><p>- Solicitud generada, con datos del miembro de familia: </p><p>- Identificación </p><p>- Nombres y apellidos </p><p>- Parentesco </p>|
|Procesamiento |<p>1. Cuando un miembro de familia no registrado inicia su proceso, el sistema genera una solicitud asociada al residente. </p><p>2. El residente recibe una notificación con los datos completos del solicitante. </p><p>3. El residente revisa la información y selecciona 'Aceptar' o 'Rechazar'. </p><p>4. Si selecciona Aceptar: </p><p>- El sistema genera un código único. </p><p>- El código tiene vigencia de 5 minutos. </p><p>- El código es de un solo uso. </p><p>- El código se envía al solicitante. </p><p>5. Si selecciona Rechazar: </p><p>- El sistema registra la decisión. </p>|



||<p>￿  Se notifica al solicitante que su solicitud ha sido rechazada. </p><p>6\.  El sistema registra fecha, hora, decisión y residente responsable. </p>|
| :- | - |
|Salidas |<p>- “Solicitud aprobada. Código enviado.” </p><p>- “Solicitud rechazada por el residente.” </p><p>- “Código expirado.” </p><p>- “Código inválido o ya utilizado.” </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo residentes activos pueden aprobar una solicitud. </p><p>2. El código generado: </p><p>- tiene validez de 3 minutos, </p><p>- solo puede usarse una vez, </p><p>- se invalida automáticamente una vez utilizado o expirado. </p><p>3. Una solicitud rechazada no genera código. </p><p>4. Todo registro debe almacenar fecha, hora y estado final. </p>|
|Dependencias |• RF – Crear Cuenta de Miembro de Familia No Registrado |
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Solicitud aprobada </p><p>Dado que el residente recibe una solicitud válida, </p><p>Cuando selecciona 'Aceptar', </p><p>Entonces el sistema genera un código único, lo envía al solicitante y muestra “Solicitud aprobada. Código enviado.” </p><p>Escenario 2 – Solicitud rechazada </p><p>Dado una solicitud enviada al residente, </p><p>Cuando selecciona 'Rechazar', </p><p>Entonces el sistema registra la decisión y notifica al solicitante. </p><p>Escenario 3 – Código expirado </p><p>Dado que el residente aprobó la solicitud hace más de 3 minutos, Cuando el solicitante intenta usar el código, </p><p>Entonces el sistema muestra “Código expirado”. </p><p>Escenario 4 – Código reutilizado </p><p>Dado que el código ya fue utilizado una vez, </p><p>Cuando el solicitante intenta usarlo nuevamente, </p><p>Entonces el sistema muestra “Código inválido o ya utilizado”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-14 </p>|

**Requerimiento Funcional RF-C05 – Bloquear Cuenta de Residente y Miembros de Familia** 



|ID |RF-C05 |
| - | - |
|Nombre |Bloquear cuenta de residente y miembros de familia |
|Descripción |El sistema permite bloquear la cuenta de un residente y, automáticamente, las cuentas de todos los miembros de familia asociados, cambiando su estado a inactivo y registrando el motivo del bloqueo. |
|Entradas |Identificación del residente, motivo de bloqueo. |
|Procesamiento |<p>1. Validar que la identificación ingresada corresponda a un residente registrado. </p><p>2. Mostrar la información del residente para confirmar identidad. </p><p>3. Solicitar ingreso del motivo de bloqueo. </p><p>4. Cambiar el estado de la cuenta del residente a 'inactivo'. </p><p>5. Identificar miembros de familia asociados y cambiar su estado a 'inactivo'. </p><p>6. Registrar la acción en el historial del sistema. </p><p>7. Mostrar mensaje de confirmación: “Las cuentas han sido bloqueadas”. </p>|
|Salidas |Mensaje de confirmación o mensaje de error si la identificación no existe. |
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El motivo de bloqueo es obligatorio. </p><p>2. No puede bloquearse una cuenta ya inactiva (el sistema debe notificarlo). </p><p>3. Al bloquear la cuenta del residente, se deben bloquear también todas las cuentas de sus miembros de familia. </p><p>4. El bloqueo no elimina información; solo cambia estados. </p><p>5. Una cuenta bloqueada no puede iniciar sesión. </p>|
|Dependencias |RF-04 (Registro de residente), RF-06 (Registro de miembro de familia), RF-05 (Baja de residente). |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Bloqueo exitoso </p><p>Dado un residente registrado con estado activo, </p><p>Cuando se ingresa su identificación, se confirma la identidad y se registra el motivo de bloqueo, </p><p>Entonces el sistema bloquea las cuentas del residente y de los miembros de familia asociados y muestra: “Las cuentas del residente y todos los miembros de familia han sido bloqueadas”. </p><p>Escenario 2 – Motivo de bloqueo no ingresado </p><p>Dado un residente válido, </p><p>Cuando el usuario no ingresa un motivo, </p><p>Entonces el sistema muestra “Error: el motivo de bloqueo es obligatorio”. </p><p>Escenario 3 – Confirmación cancelada </p><p>Dado un residente válido, </p><p>Cuando el usuario selecciona 'No' en la confirmación, Entonces el sistema cancela el proceso. </p>|



||<p>Escenario 4 – Inicio de sesión de residente bloqueado </p><p>En caso de que la cuenta del residente se encuentre bloqueada, la respuesta del sistema deberá evaluarse según: **CV-29 – Inicio de sesión con cuenta bloqueada, CV-31 – Acceso a funcionalidades privadas** </p><p>Escenario 5 – Inicio de sesión de miembro de familia bloqueado </p><p>En caso de que la cuenta del miembro de familia se encuentre bloqueada, la respuesta del sistema deberá evaluarse según: **CV-29 – Inicio de sesión con cuenta bloqueada, CV-31 – Acceso a funcionalidades privadas** </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-27, CV-28, CV-32 </p>|
| :- | - |
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-C06 – Desbloquear Cuenta de Residente y Miembros de Familia**



|ID |RF-C06 |
| - | - |
|Nombre |Desbloquear cuenta de residente y miembros de familia |
|Descripción |El sistema permite desbloquear la cuenta de un residente que se encuentra inactivo, y automáticamente desbloquear las cuentas de todos los miembros de familia asociados, restaurando su estado a activo. |
|Entradas |Identificación del residente, motivo de desbloqueo. |
|Procesamiento |<p>1. Validar que la identificación ingresada corresponda a un residente registrado. </p><p>2. Visualizar los datos del residente para confirmar identidad. </p><p>3. Verificar que el residente y sus miembros de familia estén en estado inactivo. </p><p>4. Solicitar el motivo de desbloqueo. </p><p>5. Cambiar el estado del residente a 'activo'. </p><p>6. Identificar miembros de familia asociados y cambiar su estado a 'activo'. </p><p>7. Registrar la acción en el historial del sistema. </p><p>8. Mostrar mensaje: “Las cuentas han sido desbloqueadas”. </p>|
|Salidas |Mensaje de confirmación o error si la identificación no existe. |
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El motivo de desbloqueo es obligatorio. </p><p>2. No puede desbloquearse una cuenta que ya esté activa (el sistema debe notificarlo). </p>|



||<p>3. Al desbloquear la cuenta del residente, se deben desbloquear todas las cuentas de sus miembros de familia. </p><p>4. El desbloqueo no altera información histórica, solo cambia estados. </p>|
| :- | :- |
|Dependencias |RF-09 (Bloqueo de cuentas), RF-04 (Registro de residente), RF-06 (Registro de miembro de familia). |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Desbloqueo exitoso </p><p>Dado un residente registrado con estado inactivo, </p><p>Cuando se ingresa su identificación, se confirma la identidad y se registra el motivo de desbloqueo, </p><p>Entonces el sistema activa las cuentas del residente y de los miembros de familia asociados y muestra: “Las cuentas del residente y todos los miembros de familia han sido desbloqueadas”. </p><p>Escenario 2 – Cuenta ya activa </p><p>Dado un residente cuyo estado ya es activo, </p><p>Cuando se intenta desbloquear nuevamente, </p><p>Entonces el sistema muestra “Advertencia: la cuenta ya se encuentra activa”. </p><p>Escenario 3 – Motivo de desbloqueo no ingresado </p><p>Dado un residente válido en estado inactivo, </p><p>Cuando el usuario no ingresa un motivo, </p><p>Entonces el sistema muestra “Error: el motivo de desbloqueo es obligatorio”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-28 </p>|
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-C07 – Bloquear Cuenta Individual (Residente o Miembro de Familia)** 



|ID |RF-C07 |
| - | - |
|Nombre |Bloquear cuenta individual de residente o miembro de familia |
|Descripción |El sistema permite bloquear de manera individual la cuenta de un residente o de un miembro de familia, cambiando su estado a inactivo y registrando el motivo del bloqueo, sin afectar a otros usuarios asociados. |
|Entradas |Identificación del usuario (residente o miembro de familia), motivo de bloqueo. |
|Procesamiento |<p>1. Validar que la identificación corresponda a un usuario registrado. </p><p>2. Mostrar la información del usuario para confirmar identidad. </p><p>3. Verificar que la cuenta esté activa. </p><p>4. Solicitar el motivo de bloqueo (obligatorio). </p><p>5. Cambiar el estado de la cuenta a 'inactivo'. </p>|



||<p>6. Registrar la acción en el historial del sistema. </p><p>7. Mostrar mensaje: “La cuenta del usuario ha sido bloqueada correctamente”. </p>|
| :- | - |
|Salidas |Mensaje de confirmación o mensaje de error si la identificación no existe o la cuenta ya está inactiva. |
|Prioridad |Media |
|Restricciones / Reglas de negocio |<p>1. El motivo de bloqueo es obligatorio. </p><p>2. No puede bloquearse una cuenta que ya se encuentre inactiva. </p><p>3. El bloqueo individual no afecta a otros miembros del grupo familiar ni al residente. </p><p>4. Toda acción debe registrarse en el historial del sistema. </p><p>5. Una cuenta bloqueada no puede iniciar sesión. </p>|
|Dependencias |RF-04 (Registro de residente), RF-06 (Registro de miembro de familia). |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Bloqueo individual exitoso </p><p>Dado un usuario registrado con estado activo, </p><p>Cuando se ingresa su identificación, se confirma identidad y se registra el motivo, </p><p>Entonces el sistema bloquea la cuenta y muestra: “La cuenta del usuario ha sido bloqueada correctamente”. </p><p>Escenario 4 – Motivo de bloqueo no ingresado </p><p>Dado un usuario válido en estado activo, </p><p>Cuando el operador no ingresa un motivo, </p><p>Entonces el sistema muestra “Error: el motivo de bloqueo es obligatorio”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV-27, CV-28, CV-29, CV-30, CV-31, CV-32 </p>|
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-C08 – Desbloquear Cuenta Individual (Residente o Miembro de Familia)** 



|ID |RF-C08 |
| - | - |
|Nombre |Desbloquear cuenta individual de residente o miembro de familia |
|Descripción |El sistema permite desbloquear de manera individual la cuenta de un residente o un miembro de familia que se encuentre inactiva, restaurando su estado a activo sin afectar a otros usuarios relacionados. |
|Entradas |Identificación del usuario (residente o miembro de familia), motivo de desbloqueo. |
|Procesamiento |<p>1. Validar que la identificación corresponda a un usuario registrado. </p><p>2. Mostrar la información del usuario para confirmar identidad. </p><p>3. Verificar que la cuenta esté inactiva. </p>|



||<p>4. Solicitar el motivo de desbloqueo. </p><p>5. Cambiar el estado de la cuenta a 'activo'. </p><p>6. Registrar la acción en el historial del sistema. </p><p>7. Mostrar mensaje: “La cuenta del usuario ha sido desbloqueada correctamente”. </p>|
| :- | - |
|Salidas |Mensaje de confirmación o mensaje de error si el usuario no existe o ya está activo. |
|Prioridad |Media |
|Restricciones / Reglas de negocio |<p>1. El motivo de desbloqueo es obligatorio. </p><p>2. No puede desbloquearse una cuenta que ya esté activa. </p><p>3. El desbloqueo individual no reactiva a otros miembros del grupo familiar. </p><p>4. Debe registrarse un evento de auditoría. </p>|
|Dependencias |RF-11 (Bloqueo individual), RF-09 (Bloqueo general), RF-10 (Desbloqueo general). |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Desbloqueo exitoso </p><p>Dado un usuario registrado con estado inactivo, </p><p>Cuando se ingresa su identificación, se confirma la identidad y se registra el motivo de desbloqueo, </p><p>Entonces el sistema activa la cuenta y muestra: “La cuenta del usuario ha sido desbloqueada correctamente”. </p><p>Escenario 3 – Cuenta ya activa </p><p>Dado un usuario cuyo estado ya es activo, </p><p>Cuando se intenta desbloquear nuevamente, </p><p>Entonces el sistema muestra “Advertencia: la cuenta ya se encuentra activa”. </p><p>Escenario 4 – Motivo de desbloqueo no ingresado </p><p>Dado un usuario válido con estado inactivo, </p><p>Cuando no se ingresa un motivo, </p><p>Entonces el sistema muestra “Error: el motivo de desbloqueo es obligatorio”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10, CV28 </p>|
|**Fuente / Justificación** |Entrevista con el cliente. |

**Requerimiento Funcional RF-C09 – Eliminación Definitiva de Cuenta**



|ID |RF-C09 |
| - | - |
|Nombre |Eliminación definitiva de cuenta |
|Descripción |El sistema permite eliminar de forma definitiva e irreversible la cuenta de un usuario (residente o miembro de familia). La eliminación no utiliza el estado activo/inactivo, sino un indicador de eliminación |



||permanente que impide cualquier reactivación o inicio de sesión posterior. |
| :- | :- |
|Entradas |<p>- Identificación del usuario </p><p>- Motivo de eliminación </p><p>- Confirmación final (Sí/No) </p>|
|Procesamiento |<p>1. Validar que la identificación corresponda a un usuario existente. </p><p>2. Mostrar los datos del usuario para confirmación. </p><p>3. Verificar que la cuenta no esté previamente eliminada. </p><p>4. Solicitar el motivo de eliminación (obligatorio). </p><p>5. Solicitar confirmación final (Sí/No). </p><p>6. Si la confirmación es afirmativa, marcar la cuenta como eliminada de forma definitiva (eliminado = true). </p><p>7. Registrar la acción en el historial del sistema. </p><p>8. Mostrar mensaje de confirmación. </p>|
|Salidas |“Cuenta eliminada permanentemente” o “Error: cuenta no existe”. |
|Prioridad |Media |
|Restricciones / Reglas de negocio |<p>1. La eliminación es definitiva e irreversible. </p><p>2. Una cuenta eliminada no puede reactivarse. </p><p>3. Una cuenta eliminada no puede iniciar sesión. </p><p>4. No se permite eliminar cuentas previamente eliminadas. </p><p>5. El motivo de eliminación es obligatorio. </p><p>6. Toda eliminación debe registrarse en el historial del sistema. </p>|
|Dependencias |RF-04, RF-06, RF-07, RF-08 |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Eliminación exitosa </p><p>Dado una cuenta existente y no eliminada, </p><p>Cuando el usuario confirma la eliminación, </p><p>Entonces el sistema marca la cuenta como eliminada y muestra: “Cuenta eliminada permanentemente”. </p><p>Escenario 3 – Eliminación de cuenta ya eliminada Dado una cuenta previamente eliminada, </p><p>Cuando se intenta eliminar nuevamente, </p><p>Entonces el sistema muestra: “Error: cuenta no existe”. </p><p>Escenario 4 – Inicio de sesión con cuenta eliminada Dado una cuenta marcada como eliminada, </p><p>Cuando el usuario intenta iniciar sesión, </p><p>Entonces el sistema muestra: “Error: cuenta no existe”. </p><p>Escenario 5 – Intento de reactivación de cuenta eliminada Dado una cuenta eliminada, </p><p>Cuando se intenta reactivarla, </p><p>Entonces el sistema muestra: “Error: cuenta no existe”. </p><p>Escenario 6 – Intento de generar QR desde una cuenta eliminada Dado una cuenta eliminada, </p><p>Cuando intenta generar un código QR, </p><p>Entonces el sistema muestra: “Error: cuenta no existe”. </p>|



||<p>Escenario 7 – Acceso a funcionalidades privadas </p><p>Dado una cuenta eliminada, </p><p>Cuando intenta acceder a opciones del sistema que requieren autenticación, </p><p>Entonces el sistema muestra: “Error: cuenta no existe”. </p><p>Escenario 8 – Uso de cuenta eliminada como referencia </p><p>Dado una cuenta eliminada, </p><p>Cuando se intenta utilizar para cualquier acción dependiente, Entonces el sistema muestra: “Error: cuenta no existe”. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-10 </p>|
| :- | - |

4. ***Control de Acceso mediante QR*** 

**Requerimiento Funcional RF-Q01 – Generar Código QR propio** 



|ID |RF-Q01 |
| - | - |
|Nombre |Generar código QR para residente |
|Descripción |El sistema permite que un residente o miembro de familia genere un código QR personal e intransferible que le permita ingresar por un carril preferencial sin necesidad de vehículo, definiendo un período de validez según la fecha, hora y duración configuradas. |
|Entradas |Hora de inicio del acceso, fecha del acceso, duración en horas, usuario que autoriza (residente o miembro de familia), fecha de autorización, hora de autorización, estado del código QR (vigente, caducado, utilizado, anulado). |
|Procesamiento |<p>1. Validar que el usuario que genera el código QR sea un residente o miembro de familia activo. </p><p>2. Solicitar fecha y hora de inicio del acceso. </p><p>3. Solicitar duración en horas para calcular el período de vigencia. </p><p>4. Registrar usuario autorizante, fecha y hora de autorización. </p><p>5. Generar el código QR con identificador único y parámetros de tiempo. </p><p>6. Establecer estado inicial como 'vigente'. </p><p>7. Guardar el QR en la cuenta del residente o miembro de familia. </p><p>8. Mostrar mensaje de confirmación de generación. </p>|
|Salidas |Código QR generado y mensaje: “Código QR generado correctamente”. |
|Prioridad |Media |
|Restricciones / Reglas de negocio |<p>1. El código QR es personal e intransferible; solo puede ser usado por el residente o miembro de familia que lo generó. </p><p>2. El estado del QR debe actualizarse automáticamente según su uso </p><p>&emsp;o caducidad. </p><p>3. No se puede generar un QR con fecha u hora anterior a la actual. </p>|



||<p>4\.  Solo residentes o miembros de familia activos pueden generar un </p><p>QR. </p>|
| :- | - |
|Dependencias |RF-04 (Registro de residente), RF-07 (Crear cuenta de residente). |
|Criterios de aceptación (formato Dado– Cuando– Entonces) |<p>Escenario 1 – Generación exitosa </p><p>Dado un residente activo, </p><p>Cuando ingresa fecha, hora de inicio y duración válidas, Entonces el sistema genera el código QR y muestra: “Código QR generado correctamente”. </p><p>Escenario 2 – Residente o miembro de familia inactivo </p><p>Dado un residente o miembro de familia inactivo, </p><p>Cuando intenta generar un código QR, </p><p>Entonces el sistema muestra: “Error: el residente/ miembro de familia no tiene autorización para generar códigos QR”. </p><p>Escenario 3 – Fecha u hora inválida </p><p>Dado un residente o miembro de familia activo, </p><p>Cuando ingresa fecha u hora anterior a la actual, </p><p>Entonces el sistema muestra: “Error: la fecha y hora deben ser futuras”. </p><p>Escenario 4 – Duración no válida </p><p>Dado un residente o miembro de familia activo, </p><p>Cuando ingresa una duración igual o menor a 0, </p><p>Entonces el sistema muestra: “Error: la duración debe ser mayor a 0 horas”. </p><p>Escenario 5 – Intransferibilidad </p><p>Dado un código QR generado, </p><p>Cuando otro usuario intenta utilizarlo, </p><p>Entonces el sistema rechaza el acceso y registra intento no autorizado. </p><p>Escenario 6 – Cambio automático de estado </p><p>Dado un QR vigente, </p><p>Cuando se cumple el tiempo de vigencia, </p><p>Entonces el estado cambia automáticamente a 'caducado'. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación </p>|

**Requerimiento Funcional RF-Q02 – Generar Código QR para Visita (Residente o Miembro de Familia)** 



|ID |RF-Q02 |
| - | - |
|Nombre |Generar código QR para visita |



|Descripción |El sistema permite que un residente o miembro de familia genere un código QR para autorizar el ingreso de una visita, registrando los datos de la persona visitante, la vivienda destino y un período de vigencia. |
| - | :- |
|Entradas |Identificación de la visita, nombres de la visita, apellidos de la visita, motivo de la visita, manzana, villa, fecha del acceso, hora de inicio, duración en horas, usuario que autoriza (residente o miembro de familia), fecha de autorización, hora de autorización, estado del código QR (vigente, caducado, utilizado, anulado). |
|Procesamiento |<p>1. Validar que el usuario que genera el QR sea un residente o miembro de familia activo. </p><p>2. Validar los datos de la visita. </p><p>3. Verificar que la vivienda destino (manzana y villa) coincida con la vivienda del usuario autorizante. </p><p>4. Registrar automáticamente los datos de la visita si no existen en el sistema. </p><p>5. Permitir seleccionar visitas previamente registradas para la misma vivienda. </p><p>6. Solicitar motivo de la visita. </p><p>7. Solicitar fecha y hora de inicio del acceso. </p><p>8. Solicitar duración en horas. </p><p>9. Registrar fecha, hora y usuario que autoriza. </p><p>10. Generar el código QR con identificador único y parámetros configurados. </p><p>11. Establecer estado inicial como 'vigente'. </p><p>12. Guardar el código QR generado. </p><p>13. Mostrar mensaje de confirmación. </p>|
|Salidas |Código QR generado y mensaje: “Código QR para visita generado correctamente”. |
|Prioridad |Media |
|Restricciones / Reglas de negocio |<p>1. Los datos de la visita (identificación, nombres y apellidos, tipo de visitante) son obligatorios. </p><p>2. Los datos de la visita se registran una sola vez y quedan asociados exclusivamente a la vivienda (manzana y villa) del usuario autorizante. </p><p>3. Las visitas asociadas pueden ser reutilizadas solo por las cuentas vinculadas a esa vivienda (residente y miembros de familia). </p><p>4. Usuarios de otras viviendas no podrán seleccionar visitas que no correspondan a su vivienda. </p><p>5. El QR es válido solo para la visita registrada y es intransferible. </p><p>6. Solo usuarios activos pueden generar QR. </p><p>7. No se permiten fechas u horas anteriores a la actual. </p><p>8. La duración debe ser mayor a 0 horas. </p>|
|Dependencias |RF-04 (Registro de residente), RF-06 (Registro de miembro de familia), RF-07 (Crear cuenta residente), RF-08 (Crear cuenta miembro de familia), RF-13 (Generar QR para residente). |
|Criterios de aceptación (formato Dado–|<p>Escenario 1 – Generación exitosa </p><p>Dado un usuario activo, </p><p>Cuando ingresa datos válidos de la visita, vivienda, motivo, fecha, hora </p>|



|Cuando– Entonces) |<p>y duración, </p><p>Entonces el sistema genera el QR y muestra: “Código QR para visita generado correctamente”. </p><p>Escenario 2 – Falta de datos de la visita </p><p>Dado un usuario activo, </p><p>Cuando no se ingresan la identificación, nombres o apellidos de la visita, </p><p>Entonces el sistema muestra: “Error: los datos de la visita son obligatorios”. </p><p>Escenario 3 – Usuario inactivo </p><p>Dado un residente o miembro de familia inactivo, </p><p>Cuando intenta generar el QR, </p><p>Entonces el sistema muestra: “Error: el usuario no está autorizado para generar códigos QR”. </p><p>Escenario 4 – Fecha u hora inválida </p><p>Dado un usuario activo, </p><p>Cuando se ingresa una fecha u hora en el pasado, </p><p>Entonces el sistema muestra: “Error: la fecha y hora deben ser futuras”. </p><p>Escenario 5 – Vivienda no coincide </p><p>Dado un usuario activo, </p><p>Cuando la manzana o villa no corresponde con su vivienda registrada, Entonces el sistema muestra: “Error: la vivienda seleccionada no coincide con el usuario autorizante”. </p><p>Escenario 6 – Visita reutilizable </p><p>Dado una visita previamente registrada para la misma vivienda, Cuando el usuario busca la visita en el sistema, </p><p>Entonces puede seleccionarla sin volver a ingresar datos. </p><p>Escenario 7 – Caducidad automática </p><p>Dado un QR vigente, </p><p>Cuando se cumple el tiempo de vigencia, </p><p>Entonces el estado cambia automáticamente a 'caducado'. </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación </p>|
| :- | - |

5. ***Control de Acceso sin código QR*** 

**Requerimiento Funcional RF-AQ01 – Ingreso de Visita sin Código QR** 



|ID |RF-AQ01 |
| - | - |
|Nombre |Ingreso de visitante sin código QR |



|Descripción |El sistema permite registrar el ingreso de un visitante sin código QR mediante validación con identificación física, reconocimiento facial, autorización del residente y captura de placa del vehículo. |
| - | - |
|Entradas |<p>•Nombres y apellidos,  </p><p>•Captura de identificación física mediante cámara lectora </p><p>- Manzana y villa </p><p>- Fotografía del rostro del visitante (captura en vivo) </p><p>- Motivo del ingreso (visita, delivery/pedido, taxi) </p><p>- Confirmación del residente </p><p>- Foto de placa del vehículo </p><p>- Placa de vehículo (OCR) </p>|
|Procesamiento |<p>1. El visitante coloca su identificación física frente a la cámara lectora. </p><p>2. El sistema aplica OCR a la identificación para obtener nombre y número de identificación. </p><p>3. El visitante ingresa manzana y villa del domicilio a visitar. </p><p>4. El sistema captura una fotografía del rostro del visitante. </p><p>5. Se ejecuta un reconocimiento facial para comparar rostro vs. identificación. </p><p>6. El visitante selecciona el motivo del ingreso. </p><p>7. El sistema muestra los datos del residente asociado a la vivienda. </p><p>8. El visitante confirma que la vivienda es correcta. </p><p>9. Si la verificación es satisfactoria, el sistema realiza hasta 2 llamadas automáticas al residente. </p><p>10. Si el residente autoriza, se captura la foto de placa y se aplica OCR. </p><p>11. El sistema registra el ingreso. </p><p>12. Se muestra mensaje de bienvenida y se envía señal de apertura. </p><p>13. El sistema notifica al residente sobre el ingreso. </p>|
|Salidas |<p>- Mensaje de bienvenida para el visitante </p><p>- Señal de apertura de puerta </p><p>- Notificación al residente con nombre, placa, fecha y hora </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El reconocimiento facial debe corresponder con la identificación presentada. </p><p>2. Si la verificación facial falla, el ingreso es rechazado. </p><p>3. Si el residente no contesta en 2 intentos, el ingreso se rechaza. </p><p>4. La placa debe ser capturada antes de abrir la puerta. </p><p>5. No se permite ingreso sin autorización del residente. </p><p>6. Toda la información del ingreso debe registrarse con fecha y hora. </p>|
|Dependencias |<p>- Módulo OCR de identificación </p><p>- Módulo de reconocimiento facial </p><p>- Módulo de llamadas automáticas </p><p>- Módulo OCR de placas </p><p>- Módulo de notificaciones </p>|
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Verificación facial exitosa y autorización otorgada Dado un visitante con identificación válida y reconocimiento facial exitoso, </p><p>Cuando el residente confirma el ingreso, </p><p>Entonces el sistema captura placa, abre la puerta y notifica al residente. </p>|



||<p>Escenario 2 – Reconocimiento facial falla </p><p>Dado un visitante cuya foto no coincide con su identificación, Cuando se realiza la verificación facial, </p><p>Entonces el sistema muestra “Error: identidad no verificada” y rechaza el ingreso. </p><p>Escenario 3 – Residente no responde </p><p>Dado un visitante validado, </p><p>Cuando el residente no contesta tras 2 intentos, Entonces el sistema muestra “Ingreso no autorizado”. </p><p>Escenario 4 – OCR de placa falla </p><p>Dado un visitante autorizado, </p><p>Cuando el OCR no puede leer la placa, </p><p>Entonces el sistema solicita nueva captura hasta 2 intentos. </p><p>Escenario 5 – Ingreso registrado correctamente </p><p>Dado un visitante autorizado y con placa capturada, Cuando el sistema registra el ingreso, </p><p>Entonces muestra mensaje de bienvenida y abre la puerta. </p><p>Escenario 6 – Notificación al residente </p><p>Dado un ingreso exitoso, </p><p>Cuando el visitante pasa el punto de control, </p><p>Entonces el sistema notifica al residente con nombre, placa, fecha y hora. </p>|
| :- | - |

**Requerimiento Funcional RF-AQ02 – Autorización Manual de Visita por Guardia** 



|ID |RF-AQ02 |
| - | - |
|Nombre |Registrar autorización manual de visita por guardia |
|Descripción |El sistema permite registrar una autorización manual de ingreso cuando el residente no responde a las llamadas automáticas durante el proceso de ingreso sin QR. El guardia verifica presencialmente la autorización y registra toda la información en el sistema. |
|Entradas |<p>- Nombres y apellidos del visitante </p><p>- Identificación del visitante (OCR) </p><p>- Manzana y villa </p><p>- Fecha y hora </p><p>- Placa del vehículo </p><p>- Fotografía del visitante </p><p>- Fotografía de la placa </p><p>- Motivo del ingreso (visita, delivery/pedido, taxi) </p><p>- Resultado de autorización (autorizado/no autorizado) </p><p>- Identificación del guardia </p>|
|Procesamiento |<p>1. Tras dos llamadas fallidas al residente, el sistema habilita la opción de autorización manual. </p><p>2. El guardia verifica presencialmente si el residente autoriza o rechaza la visita. </p>|



||<p>3. El guardia registra los datos del visitante, vehículo, motivo y resultado. </p><p>4. Si el residente autoriza, el sistema continúa el flujo normal de ingreso. </p><p>5. Si rechaza, el sistema bloquea el ingreso y registra el evento. </p><p>6. El sistema notifica al residente sobre el ingreso exitoso o fallido, incluyendo los datos del visitante. </p><p>7. El sistema almacena toda la información en el historial de visitas. </p>|
| :- | :- |
|Salidas |<p>- “Visita autorizada manualmente” </p><p>- “Visita rechazada por el residente” </p><p>- Registro en historial de visitas </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. La autorización manual solo es posible luego de dos llamadas sin respuesta. </p><p>2. Solo guardias autenticados pueden registrar la acción. </p><p>3. Toda la información debe registrarse con fecha y hora. </p><p>4. La autorización manual tiene el mismo peso que una autorización telefónica o QR. </p><p>5. No se permite modificar un registro después de guardado. </p>|
|Dependencias |<p>- RF Ingreso visitante sin QR </p><p>- Módulo OCR de identificación </p><p>- Módulo OCR de placas </p><p>- Módulo de historial </p><p>- Módulo de notificaciones </p><p>- Módulo de autenticación de guardias </p>|
|Criterios de aceptación (Dado–Cuando– Entonces) |<p>Escenario 1 – Autorización manual exitosa </p><p>Dado un visitante con llamadas fallidas, </p><p>Cuando el guardia registra que el residente autoriza, Entonces el sistema permite el ingreso y lo registra. </p><p>Escenario 2 – Autorización rechazada </p><p>Dado un visitante en proceso de autorización manual, Cuando el residente indica presencialmente que no autoriza, Entonces el sistema bloquea el ingreso y registra el evento. </p><p>Escenario 3 – Intento anticipado de autorización manual </p><p>Dado un proceso en curso, </p><p>Cuando se intenta registrar autorización antes de las dos llamadas, Entonces el sistema muestra: “La autorización manual solo está disponible tras dos intentos fallidos de llamada”. </p><p>Escenario 4 – Guardia no autorizado </p><p>Dado un usuario no autenticado como guardia, </p><p>Cuando intenta registrar autorización manual, </p><p>Entonces el sistema muestra: “Acceso restringido: solo guardias autorizados pueden realizar esta acción”. </p><p>Escenario 5 – Registro completo en historial Dado que se realiza una autorización manual, </p>|



||<p>Cuando el guardia guarda la información, </p><p>Entonces el sistema almacena todos los datos del visitante, vehículo, motivo y resultado. </p>|
| :- | - |

**Requerimiento Funcional RF-AQ03 – Llamada Telefónica de Autorización al Residente** 



|ID |RF-AQ03 |
| - | - |
|Nombre |Llamada Telefónica de Autorización al Residente |
|Descripción |El sistema realiza una llamada telefónica automática al residente para solicitar la autorización de ingreso de una visita. La llamada incluye un mensaje personalizado con los datos de la visita y el motivo del ingreso. El residente selecciona una opción (aceptar o rechazar) y el sistema procesa esa respuesta para continuar con el flujo correspondiente. |
|Entradas |<p>- Número telefónico del residente. </p><p>- Datos de la visita (nombre, identificación, placa, tipo de vista). </p><p>- Motivo de ingreso. </p><p>- Mensaje personalizado. </p><p>- Tiempo máximo de respuesta. </p><p>- Opciones disponibles: 1 = Autorizar, 2 = Rechazar. </p>|
|Procesamiento |<p>1. Recibir solicitud desde el módulo de ingreso. </p><p>2. Obtener número telefónico del residente. </p><p>3. Construir mensaje con datos de la visita. </p><p>4. Realizar la llamada automática. </p><p>5. Reproducir el mensaje personalizado. </p><p>6. Presentar opciones al residente. </p><p>7. Capturar selección mediante DTMF. </p><p>8. Validar respuesta (1=Autorizado, 2=Rechazado, Sin respuesta). </p><p>9. Registrar evento en bitácora. </p><p>10. Retornar resultado al módulo solicitante. </p>|
|Salidas |<p>- “Autorización aceptada por el residente”. </p><p>- “Autorización rechazada por el residente”. </p><p>- “No hubo respuesta del residente”. </p><p>- Códigos: ACEPTADO / RECHAZADO / SIN\_RESPUESTA. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. La llamada solo se realiza al residente principal. </p><p>2. El número telefónico debe ser válido (CV-06). </p><p>3. Existe un tiempo máximo de respuesta. </p><p>4. Si la llamada falla, se registra como 'sin respuesta'. </p><p>5. La autorización es válida para un solo ingreso. </p><p>• Este requisito aplica los criterios de validación: CV-05, CV-06, CV-11, CV-12. </p>|
|Dependencias |RF-V01 – Ingreso de Visita sin Código QR. RF-V02 – Generar Código QR para Visita. RF-B01 – Validación biométrica del visitante. Validaciones: CV-05, CV-06, CV-11, CV-12. |
|Criterios de aceptación |<p>Escenario 1 – Autorización exitosa </p><p>Dado que el residente recibe la llamada, Cuando presiona la opción 1, </p><p>Entonces el sistema registra autorización. </p>|



||<p>Escenario 2 – Autorización rechazada Dado que el residente recibe la llamada, Cuando presiona la opción 2, </p><p>Entonces el sistema registra rechazo. </p><p>Escenario 3 – Sin respuesta del residente Dado que el sistema realiza la llamada, Cuando expira el tiempo máximo, Entonces registra 'sin respuesta'. </p><p>Escenario 4 – Número inválido </p><p>Dado un número telefónico inválido, Cuando se intenta realizar la llamada, Entonces se muestra error. </p><p>Escenario 5 – Llamada fallida </p><p>Dado un fallo del proveedor telefónico, Cuando se detecta la falla, </p><p>Entonces se registra 'sin respuesta'. </p>|
| :- | :- |

**Requerimiento Funcional RF-AQ04 – Ingreso de Visita Peatonal** 



|ID |RF-AQ04 |
| - | - |
|Nombre |Ingreso de Visita Peatonal |
|Descripción |El sistema permite registrar el ingreso de una visita peatonal, validando identidad, capturando fotografía en vivo y gestionando la autorización del residente. |
|Entradas |<p>- Nombres y apellidos. </p><p>- Identificación. </p><p>- Manzana y villa. </p><p>- Fotografía del rostro (captura en vivo). </p><p>- Motivo del ingreso. </p><p>- Confirmación del residente. </p>|
|Procesamiento |<p>1. Registrar datos del visitante. </p><p>2. Capturar fotografía en vivo. </p><p>3. Validar existencia de la vivienda (manzana y villa). </p><p>4. Obtener residente asignado a la vivienda. </p><p>5. El guardia realiza la llamada para autorización. </p><p>6. Registrar respuesta del residente. </p><p>7. Si autoriza, capturar segunda fotografía y registrar ingreso. </p><p>8. Si rechaza o no responde, registrar ingreso no autorizado. </p>|
|Salidas |<p>- Registro de ingreso autorizado. </p><p>- Registro de intento fallido. </p><p>- Registro en bitácora del evento. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo residentes activos pueden autorizar ingresos. </p><p>2. La fotografía debe ser una captura en vivo válida. </p><p>3. No se permite ingreso si la vivienda no tiene residente activo. </p>|



||<p>4. Motivo del ingreso obligatorio. </p><p>5. Guardia no puede autorizar sin aprobación del residente. </p><p>• Criterios: CV-01, CV-03, CV-05, CV-09, CV-11, CV-12. </p>|
| :- | - |
|Dependencias |RF-V03, RF-C01, RF-C02, CV-01, CV-03, CV-05, CV-09, CV-11, CV-12 |
|Criterios de aceptación |<p>Escenario 1 – Ingreso autorizado </p><p>Dado un visitante válido y residente que autoriza, Cuando el guardia registra la autorización, Entonces el sistema registra el ingreso. </p><p>Escenario 2 – Ingreso rechazado </p><p>Dado un visitante válido, </p><p>Cuando el residente rechaza, </p><p>Entonces el ingreso es registrado como no autorizado. </p><p>Escenario 3 – Fotografía inválida </p><p>Dado que se captura la fotografía del visitante, </p><p>Cuando la imagen no presenta rostro válido, </p><p>Entonces el sistema muestra 'Error: fotografía no válida'. </p><p>Escenario 4 – Vivienda inexistente </p><p>Dado que se ingresa manzana y villa, </p><p>Cuando la vivienda no existe, </p><p>Entonces el sistema muestra 'Error: vivienda no registrada'. </p><p>Escenario 5 – Residente no responde </p><p>Dado que se realizan llamadas al residente, </p><p>Cuando el residente no responde, </p><p>Entonces el sistema marca el ingreso como no autorizado. </p>|

**Requerimiento Funcional RF-AQ05 – Ingreso Automático de Residente Activo** 



|ID |RF-AQ05 |
| - | - |
|Módulo |Control de Accesos sin Código QR |
|Nombre |Ingreso Automático de Residente Activo |
|Descripción |El sistema permite el ingreso automático de residentes activos mediante validación biométrica facial y validación de placa vehicular, capturando imágenes en vivo y comparándolas con los registros existentes. |
|Entradas |<p>- Identificación del residente. </p><p>- Fotografía del rostro (captura en vivo). </p><p>- Fotografía de la placa del vehículo (captura en vivo). </p><p>- Datos OCR de la placa. </p>|
|Procesamiento |<p>1. Capturar fotografía en vivo del rostro del residente. </p><p>2. Capturar fotografía en vivo de la placa del vehículo. </p><p>3. Aplicar OCR a la placa. </p><p>4. Validar que el residente esté activo. </p><p>5. Comparar rostro con registros existentes. </p><p>6. Comparar placa con registros del residente. </p><p>7. Si ambas validaciones son exitosas, abrir puertas automáticas. </p>|



||<p>8. Si falla una validación, mostrar mensaje de error. </p><p>9. Tras dos fallos consecutivos, activar protocolo manual por guardia. </p>|
| :- | - |
|Salidas |<p>- Registro de ingreso autorizado. </p><p>- Registro de intentos fallidos. </p><p>- Apertura de puertas automáticas. </p><p>- Activación de protocolo manual. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo residentes activos pueden usar el ingreso automático. </p><p>2. Capturas deben ser en vivo y válidas. </p><p>3. Se permiten máximo dos intentos fallidos. </p><p>4. Tras dos fallos se activa el protocolo manual del guardia. </p>|
|Dependencias |RF-C01, RF-C02, RF-AQ02, RF-R01, RF-R05 |
|Criterios de aceptación |<p>Escenario 1 – Ingreso exitoso </p><p>Dado un residente activo con rostro y placa válidos, Cuando el sistema valida ambos, </p><p>Entonces se abre la puerta y se registra el ingreso. </p><p>Escenario 2 – Dos fallos consecutivos </p><p>Dado que ocurren dos fallos seguidos, </p><p>Cuando se intenta nuevamente ingresar, </p><p>Entonces se activa el protocolo manual por guardia. </p><p>Escenario 3 – Validación de placa exitosa </p><p>Dado un residente activo con una o más placas registradas en el sistema, </p><p>Y dado que se captura en vivo una fotografía de la placa del vehículo, Cuando el sistema aplica OCR a la imagen y el número de placa extraído coincide con una placa registrada para ese residente, </p><p>Entonces el sistema confirma la validación de placa como exitosa y permite continuar con el flujo de ingreso automático. </p><p>Escenario 4 – Fallo en validación de placa </p><p>Dado un residente activo, </p><p>Cuando el OCR de la placa no coincide con la placa registrada, Entonces el sistema muestra “Error: placa vehicular no coincide.” </p><p>Escenario adicional – Aplicación de criterios de validación comunes Dado que este requisito está sujeto a criterios de validación transversales, </p><p>Cuando se ejecute la validación correspondiente, </p><p>Entonces deberán aplicarse los criterios de validación CV-14, CV-19, CV-20 </p>|

**Requerimiento Funcional RF-AQ06 – Salida Automática de Residente Activo** 



|ID |RF-AQ06 |
| - | - |
|Módulo |Control de Accesos sin Código QR |



|Nombre |Salida Automática de Residente Activo |
| - | - |
|Descripción |El sistema permite la salida automática de residentes activos mediante validación biométrica facial y validación de placa vehicular, capturando imágenes en vivo y comparándolas con los registros existentes. |
|Entradas |<p>- Identificación del residente. </p><p>- Fotografía del rostro (captura en vivo). </p><p>- Fotografía de la placa del vehículo (captura en vivo). </p><p>- Datos OCR de la placa. </p>|
|Procesamiento |<p>1. Capturar fotografía en vivo del rostro del residente. </p><p>2. Capturar fotografía en vivo de la placa del vehículo. </p><p>3. Aplicar OCR a la placa. </p><p>4. Validar que el residente esté activo. </p><p>5. Comparar rostro con registros existentes. </p><p>6. Comparar placa con registros del residente. </p><p>7. Si ambas validaciones son exitosas, abrir puertas automáticas de salida. </p><p>8. Si falla una validación, mostrar mensaje de error. </p><p>9. Tras dos fallos consecutivos, activar protocolo manual por guardia. </p>|
|Salidas |<p>- Registro de salida autorizada. </p><p>- Registro de intentos fallidos. </p><p>- Apertura automática de puertas de salida. </p><p>- Activación de protocolo manual. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo residentes activos pueden usar la salida automática. </p><p>2. Capturas deben ser en vivo y válidas. </p><p>3. La placa debe estar registrada para el residente. </p><p>4. Se permiten máximo dos intentos fallidos. </p><p>5. Tras dos fallos se activa el protocolo manual del guardia. </p>|
|Dependencias |RF-C01, RF-C02, RF-AQ02, RF-R01, RF-R05 |
|Criterios de aceptación |<p>Escenario 1 – Salida exitosa </p><p>Dado un residente activo con rostro y placa válidos, Cuando el sistema valida ambos, </p><p>Entonces se abre la puerta de salida y se registra el evento. </p><p>Escenario 2 – Dos fallos consecutivos Dado que ocurren dos fallos seguidos, </p>|



||<p>Cuando se intenta nuevamente salir, </p><p>Entonces se activa el protocolo manual por guardia. </p>|
| :- | - |

**Requerimiento Funcional RF-AQ07 – Salida de Visitante** 



|ID |RF-AQ07 |
| - | - |
|Módulo |Control de Accesos sin Código QR |
|Nombre |Salida de Visitante |
|Descripción |El sistema permite registrar la salida de un visitante que ingresó en vehículo con o sin código QR, aplicando un protocolo de revisión vehicular realizado por el guardia y notificando al residente correspondiente. |
|Entradas |<p>- Nombres y apellidos del visitante. </p><p>- Manzana y villa. </p><p>- Fecha de salida. </p><p>- Hora de salida. </p><p>- Observación (opcional). </p>|
|Procesamiento |<p>1. El guardia selecciona o ingresa los datos del visitante. </p><p>2. El sistema valida que exista un ingreso previo. </p><p>3. El guardia aplica el protocolo de revisión del vehículo. </p><p>4. Si la revisión es satisfactoria, confirma la salida. </p><p>5. El sistema registra fecha y hora de salida. </p><p>6. El sistema registra observaciones si existen. </p><p>7. El sistema envía la señal de apertura de la puerta. </p><p>8. El sistema notifica al residente sobre la salida del visitante. </p>|
|Salidas |<p>- Registro de salida del visitante. </p><p>- Apertura automática de puerta. </p><p>- Notificación al residente. </p><p>- Registro en bitácora. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo visitantes con ingreso previo pueden registrar salida. </p><p>2. La revisión vehicular por el guardia es obligatoria. </p><p>3. El guardia es el único autorizado para confirmar la revisión. </p><p>4. La fecha y hora de salida no pueden ser anteriores al ingreso. </p><p>5. Observaciones son opcionales. </p>|
|Dependencias |RF-AQ03, RF-AQ02, RF-B03 |



|Criterios de aceptación |<p>Escenario 1 – Salida registrada correctamente </p><p>Dado un visitante con ingreso previo, </p><p>Cuando el guardia confirma la revisión y registra la salida, Entonces el sistema registra la salida, abre la puerta y notifica al residente. </p><p>Escenario 2 – Visitante sin ingreso previo Dado un visitante sin ingreso registrado, Cuando se intenta registrar la salida, Entonces el sistema muestra error. </p><p>Escenario 3 – Revisión no aprobada Dado un visitante con ingreso previo, Cuando la revisión no es aprobada, Entonces no se autoriza la salida. </p><p>Escenario 4 – Fecha u hora inválida </p><p>Dado un visitante con ingreso válido, Cuando la fecha u hora de salida es inválida, Entonces el sistema muestra error. </p><p>Escenario 5 – Notificación al residente Dado que la salida fue registrada, Cuando el sistema finaliza el proceso, Entonces se notifica al residente. </p>|
| :- | - |

6. ***OCR, Reconocimiento Facial y Validación de identidad*  Requerimiento Funcional RF-OB01 – Validación Biométrica de Rostro** 

 

|ID |RF-OB01 |
| - | - |
|Nombre |Validación Biométrica de Rostro |
|Descripción |El sistema permite validar la identidad de un usuario mediante una captura en vivo de su rostro, comparándola con las fotografías de rostro almacenadas en la base de datos para dicho usuario. |
|Entradas |<p>- Identificación del usuario. </p><p>- Tipo de usuario. </p><p>- Contexto de validación. </p><p>- Captura en vivo del rostro. </p><p>- Lista de fotografías de rostro previamente registradas. </p>|
|Procesamiento |<p>1. Verificar existencia y estado del usuario. </p><p>2. Recuperar lista de fotografías almacenadas. </p><p>3. Validar que las fotos sean válidas (JPG/PNG, calidad mínima). </p><p>4. Tomar captura en vivo desde la cámara. </p><p>5. Validar calidad de la imagen capturada. </p>|



||<p>6. Ejecutar reconocimiento facial. </p><p>7. Comparar similitud contra cada foto registrada. </p><p>8. Aprobar o rechazar en función del umbral. </p><p>9. Registrar el evento en bitácora. </p><p>10. Retornar resultado al módulo solicitante. </p>|
| :- | - |
|Salidas |<p>- “Validación biométrica exitosa”. </p><p>- “Error: no se encontraron fotografías registradas”. </p><p>- “Error: rostro no coincide con el registrado”. </p><p>- “Error: imagen capturada no cumple requisitos de calidad”. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. La validación solo se realiza para usuarios existentes. </p><p>2. Las fotografías deben ser propias del usuario. </p><p>3. La lista de fotografías no debe estar vacía. </p><p>4. La captura debe provenir de cámara autorizada. </p><p>5. Se usa un umbral de similitud configurable. </p><p>6. Tras múltiples fallos se bloquea temporalmente. </p><p>• Este requisito aplica los criterios de validación: CV-01, CV-09, CV-11, CV-12. </p>|
|Dependencias |<p>RF-P01, RF-P02, RF-R01, RF-R02 </p><p>Criterios comunes: CV-01, CV-09, CV-11, CV-12. </p>|
|Criterios de aceptación |<p>Escenario 1 – Validación biométrica exitosa Dado un usuario con fotografías válidas, Cuando se realiza la captura en vivo y coincide, Entonces el sistema retorna éxito. </p><p>Escenario 2 – Rostro no coincide </p><p>Dado un usuario con fotos registradas, Cuando la similitud no supera el umbral, Entonces el sistema rechaza. </p><p>Escenario 3 – Usuario sin fotografías </p><p>Dado un usuario sin fotos registradas, Cuando se intenta validar biométricamente, Entonces el sistema muestra error. </p><p>Escenario 4 – Captura en vivo con mala calidad Dado una captura borrosa o inválida, </p><p>Cuando se intenta validar, </p><p>Entonces el sistema muestra error. </p><p>Escenario 5 – Número máximo de intentos </p><p>Dado múltiples intentos fallidos, </p><p>Cuando se supera el límite configurado, </p><p>Entonces se bloquea temporalmente la validación. </p>|

**Requerimiento Funcional RF-OB02 – Aplicación de OCR al Documento de Identidad** 



|ID |RF-OB02 |
| - | - |
|Nombre |Aplicación de OCR al Documento de Identidad |



|Descripción |El sistema permite extraer automáticamente los datos personales de un usuario mediante la aplicación de OCR sobre una imagen del documento de identidad, con el fin de agilizar procesos de registro, verificación o validación de identidad. |
| - | :- |
|Entradas |<p>- Imagen del documento de identidad (frontal). </p><p>- Tipo de identificación. </p><p>- Parámetros mínimos de calidad de imagen. </p>|
|Procesamiento |<p>1. Recibir la imagen del documento. </p><p>2. Validar que la imagen esté en formato JPG/PNG, no vacía y cumpla requisitos de calidad. </p><p>3. Aplicar preprocesamiento (rotación, contraste, limpieza de ruido). </p><p>4. Ejecutar OCR sobre el área de texto del documento. </p><p>5. Extraer nombres, apellidos e identificación. </p><p>6. Validar legibilidad y consistencia de los datos. </p><p>7. Registrar en bitácora el resultado y nivel de confianza. </p><p>8. Retornar datos al módulo solicitante. </p>|
|Salidas |<p>- Nombres. </p><p>- Apellidos. </p><p>- Identificación. </p><p>- Mensajes de error según corresponda. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. El documento debe pertenecer al usuario en proceso. </p><p>2. Solo se aceptan imágenes JPG/PNG. </p><p>3. El OCR debe cumplir un nivel mínimo de confianza. </p><p>4. Si el documento es ecuatoriano, la identificación debe validarse con CV-01. </p><p>&emsp;• Este requisito aplica los criterios de validación: CV-01, CV-09 </p>|
|Dependencias |RF-B01 – Validación biométrica. |
|Criterios de aceptación |<p>Escenario 1 – OCR exitoso </p><p>Dado un documento claro y legible, </p><p>Cuando el sistema aplica OCR, </p><p>Entonces extrae correctamente nombres, apellidos e identificación. </p><p>Escenario 2 – Imagen con mala calidad Dado una imagen borrosa o inválida, Cuando se intenta aplicar OCR, Entonces el sistema muestra error. </p><p>Escenario 3 – Datos no legibles </p><p>Dado una imagen válida pero con texto dañado, </p><p>Cuando se procesa OCR, </p><p>Entonces se muestra “Error: no se pudo extraer información válida”. </p><p>Escenario 4 – Identificación inválida </p><p>Dado que la identificación extraída no cumple reglas del país, Cuando se valida la estructura, </p><p>Entonces el sistema muestra “Error: identificación inválida”. </p>|

7. ***Notificaciones*** 

**Requerimiento Funcional RF-N01 – Notificaciones Masivas Push a Residentes** 



|ID |RF-N01 |
| - | - |
|Nombre |Notificaciones Masivas Push a Residentes |
|Descripción |El sistema permite enviar un mensaje push masivo a todos los residentes activos. |
|Entradas |<p>- Mensaje a difundir. </p><p>- Usuario autorizado que emite la notificación. </p><p>- Fecha y hora de envío. </p>|
|Procesamiento |<p>1. Recibir mensaje. </p><p>2. Validar que no esté vacío. </p><p>3. Obtener residentes activos. </p><p>4. Construir notificación push. </p><p>5. Enviar notificación push. </p><p>6. Registrar en bitácora. </p><p>7. Retornar confirmación. </p>|
|Salidas |<p>- Notificación push enviada. </p><p>- Registro en bitácora. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo usuarios autorizados pueden enviar notificaciones. </p><p>2. Solo residentes activos reciben notificaciones. </p><p>3. El mensaje no puede estar vacío. </p><p>4. El envío se realiza solo por notificaciones push. </p><p>• Este requisito aplica los criterios de validación: CV-03, CV-05, CV-11, CV-12. </p>|
|Dependencias |<p>RF-R01, RF-R04, RF-R05. </p><p>Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Criterios de aceptación |<p>Escenario 1 – Envío exitoso </p><p>Dado un mensaje válido y usuario autorizado, Cuando se envía, </p><p>Entonces llega a todos los residentes activos. </p><p>Escenario 2 – Mensaje vacío Dado un intento de envío, Cuando el mensaje está vacío, Entonces se muestra error. </p><p>Escenario 3 – Sin residentes activos </p><p>Dado que no hay residentes activos, Cuando se intenta enviar, </p><p>Entonces se muestra aviso correspondiente. </p>|

**Requerimiento Funcional RF-N02 – Notificaciones Masivas Push a Propietarios** 



|ID |RF-N02 |
| - | - |
|Nombre |Notificaciones Masivas Push a Propietarios |
|Descripción |El sistema permite enviar un mensaje push masivo a todos los propietarios activos. |
|Entradas |<p>- Mensaje a difundir. </p><p>- Usuario emisor autorizado. </p><p>- Fecha y hora automatizada. </p>|
|Procesamiento |<p>1. Recibir mensaje. </p><p>2. Validar contenido. </p><p>3. Obtener propietarios activos. </p><p>4. Construir notificación push. </p><p>5. Enviar. </p><p>6. Registrar envío. </p><p>7. Retornar confirmación. </p>|
|Salidas |<p>- Notificación push enviada. </p><p>- Registro en bitácora. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo usuarios autorizados pueden enviar. </p><p>2. Solo propietarios activos reciben notificaciones. </p><p>3. Mensaje debe ser válido. </p><p>4. Envío exclusivo por notificaciones push. </p><p>• Este requisito aplica los criterios de validación: CV-03, CV-05, CV-11, CV-12. </p>|
|Dependencias |<p>RF-P01, RF-P04, RF-P05. </p><p>Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Criterios de aceptación |<p>Escenario 1 – Envío correcto </p><p>Dado un mensaje válido, </p><p>Cuando se envía, </p><p>Entonces llega a todos los propietarios activos. </p><p>Escenario 2 – Mensaje inválido </p><p>Dado un intento de envío, </p><p>Cuando el mensaje es vacío o inválido, Entonces se muestra error. </p><p>Escenario 3 – Sin propietarios activos Dado que no existen propietarios activos, Cuando se intenta enviar, </p><p>Entonces el sistema lo indica. </p>|

**Requerimiento Funcional RF-N03 – Notificación Individual a Residente** 



|ID |RF-N03 |
| - | - |
|Nombre |Notificación Individual a Residente |
|Descripción |El sistema permite enviar una notificación push individual a un residente activo. |
|Entradas |<p>- Identificador del residente. </p><p>- Mensaje a difundir. </p><p>- Usuario autorizado. </p><p>- Fecha y hora automática. </p>|
|Procesamiento |<p>1. Recibir identificador y mensaje. </p><p>2. Validar mensaje. </p><p>3. Validar existencia del residente. </p><p>4. Verificar estado activo. </p><p>5. Construir notificación push. </p><p>6. Enviar notificación. </p><p>7. Registrar envío. </p><p>8. Retornar confirmación. </p>|
|Salidas |<p>- Notificación push enviada. </p><p>- Registro del envío. </p><p>- Mensajes de error. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo usuarios autorizados pueden enviar. </p><p>2. El mensaje no puede estar vacío. </p><p>3. Solo residentes activos reciben notificaciones. </p><p>4. Envío exclusivo por notificaciones push. </p><p>• Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Dependencias |<p>RF-R01, RF-R04, RF-R05. </p><p>Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Criterios de aceptación |<p>Escenario 1 – Notificación enviada </p><p>Dado un residente activo, </p><p>Cuando se envía un mensaje válido, Entonces se entrega la notificación push. </p><p>Escenario 2 – Mensaje vacío Dado un intento de envío, Cuando el mensaje está vacío, Entonces se muestra error. </p><p>Escenario 3 – Residente no activo Dado un residente existente, Cuando su estado no es activo, Entonces se muestra error. </p><p>Escenario 4 – Residente inexistente Dado un identificador no registrado, Cuando se intenta enviar, </p><p>Entonces se muestra error. </p>|

**Requerimiento Funcional RF-N04 – Notificación Individual a Propietario** 



|ID |RF-N04 |
| - | - |
|Nombre |Notificación Individual a Propietario |
|Descripción |El sistema permite enviar una notificación push individual a un propietario activo. |
|Entradas |<p>- Identificador del propietario. </p><p>- Mensaje a difundir. </p><p>- Usuario autorizado. </p><p>- Fecha y hora automática. </p>|
|Procesamiento |<p>1. Recibir identificador y mensaje. </p><p>2. Validar mensaje. </p><p>3. Verificar existencia del propietario. </p><p>4. Confirmar estado activo. </p><p>5. Construir notificación push. </p><p>6. Enviar. </p><p>7. Registrar evento. </p><p>8. Retornar respuesta. </p>|
|Salidas |<p>- Notificación push enviada. </p><p>- Registro en bitácora. </p><p>- Errores según aplique. </p>|
|Prioridad |Alta |
|Restricciones / Reglas de negocio |<p>1. Solo usuarios autorizados pueden enviar. </p><p>2. Mensaje no puede estar vacío. </p><p>3. Solo propietarios activos reciben notificaciones. </p><p>4. Envío exclusivo por push. </p><p>• Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Dependencias |<p>RF-P01, RF-P04, RF-P05. </p><p>Criterios: CV-03, CV-05, CV-11, CV-12. </p>|
|Criterios de aceptación |<p>Escenario 1 – Envío exitoso </p><p>Dado un propietario activo y un mensaje válido, Cuando se envía, </p><p>Entonces llega la notificación push. </p><p>Escenario 2 – Mensaje inválido Dado un intento de envío, Cuando el mensaje está vacío, Entonces se muestra error. </p><p>Escenario 3 – Propietario no activo Dado un propietario existente, Cuando su estado no es activo, Entonces se muestra error. </p><p>Escenario 4 – Propietario inexistente Dado un identificador no registrado, Cuando se intenta enviar, </p><p>Entonces se muestra error. </p>|

3. **Criterios de Validación Comunes (CV-xx) – Detallados** 

**CV-01 – Identificación ecuatoriana inválida**  

Dado una identificación ecuatoriana... Cuando la nacionalidad es Ecuador... Entonces se valida cédula/RUC. 

**CV-02 – Identificación extranjera no vacía** 

Dado un usuario extranjero... 

Cuando ingresa identificación... 

Entonces solo se verifica que no esté vacía. 

**CV-03 – Nombres o apellidos vacíos** 

Dado nombres o apellidos vacíos... Cuando intenta registrar... Entonces se muestra error. 

**CV-04 – Fecha de nacimiento mayor edad inválida** 

Dado fecha futura o menor de 18 años... 

Cuando intenta registrar... 

Entonces el sistema muestra 'Error: la fecha de nacimiento debe corresponder a una persona mayor de 18 años y no puede ser futura', y se rechaza. 

**CV-05 – Correo electrónico inválido** 

Dado correo electrónico que no cumple el formato usuario@dominio.com... Cuando intenta guardar... 

Entonces se muestra “Formato incorrecto”. 

**CV-06 – Celular ecuatoriano incorrecto** 

Dado celular fuera de 09XXXXXXXX... Cuando intenta registrar... 

Entonces se rechaza. 

**CV-07 – Vivienda inexistente** 

Dado manzana/villa inexistente... Cuando intenta registrar... Entonces se muestra error. 

**CV-08 – Documento PDF inválido** 

Dado documento no PDF o vacío... Cuando intenta guardar... Entonces se rechaza. 

**CV-09 – Fotografías no válidas** 

Dado fotos vacías o en formato distinto a JPG/PNG o de igual resolución... Cuando intenta registrar... 

Entonces 'Error: la fotografía debe ser un archivo JPG/PNG válido y no vacío'. 

**CV-10 – Identificación inexistente** 

Dado identificación inexistente... 

Cuando se requiere existencia... 

Entonces el sistema muestra “Error: {propietario | residente | miembro} no existe”. 

**CV-11 – Cuenta bloqueada** Dado cuenta bloqueada... Cuando intenta iniciar sesión... Entonces se bloquea. 

**CV-12 – Cuenta eliminada** Dado cuenta bloqueada... Cuando inicia sesión... Entonces error. 

**CV–13 –** **Estado activo de personas registradas** 

Dado una persona registrada con rol {propietario | residente} en estado “activo”, 

Cuando se consulta su identificación, 

Entonces el sistema responde con el comportamiento definido por las reglas de negocio del módulo correspondiente. 

**CV–14 –** **Estado inactivo de personas registradas** 

Dado una persona registrada con rol {propietario | residente | miembro} en estado “inactivo”, Cuando se consulta su identificación, 

Entonces el sistema muestra “Error: {propietario | residente  | miembro} inactivo”. 

**CV-15 – Dirección alternativa (opcional)** 

Dado una propietario que no ingresa una dirección alternativa. 

Cuando el usuario guarda el registro. 

Entonces el sistema acepta el registro sin error y guarda la información correctamente. 

**CV-16 – Fecha de nacimiento inválida** 

Dado un cónyuge con fecha de nacimiento mayor a la actual o formato diferente al DD-MM- YYYY 

Cuando el usuario intenta guardar el registro, 

Entonces el sistema muestra “Error: la fecha de nacimiento es futuro o no está en formato DD-MM-YYYY” y no guarda el registro. 

**CV-17 – Vivienda no asociada a la persona registrada** 

Dado una manzana y una villa que no corresponden a la vivienda asociada a la persona registrada {propietario | residente}, 

Cuando el usuario intenta guardar el registro, 

Entonces el sistema muestra el mensaje “Error: la manzana y la villa no coinciden con la vivienda del {propietario | residente}” 

y no guarda el registro. 

**CV-18 – Identificación duplicada** 

Dado un identificación ya existe en el sistema, 

Cuando el usuario intenta registrar el {propietario | residente | miembro}, 

Entonces el sistema muestra “Error: el número de identificación ya está registrado” y no guarda el registro. 

**CV-19 – Reconocimiento facial exitoso** 

Dado que la captura coincide con la fotografía registrada, 

Cuando se valida la biometría, 

Entonces el sistema responde con el comportamiento definido por las reglas de negocio del módulo correspondiente. 

**CV-20 – Reconocimiento facial fallido** 

Dado que el rostro no coincide, 

Cuando intenta continuar, 

Entonces el sistema muestra “Error: reconocimiento facial fallido”. 

**CV-21 – Contraseña y confirmación coinciden** 

Dado contraseña y confirmación iguales y válidas, 

Cuando confirma los datos, 

Entonces el sistema responde con el comportamiento definido por las reglas de negocio del módulo correspondiente. 

**CV-22 – Contraseñas no coinciden** 

Dado que se ingresó contraseña y confirmación, 

Cuando estas no coinciden, 

Entonces el sistema muestra “Error: las contraseñas no coinciden”. 

**CV-23 – Contraseña inválida** 

Dado una contraseña que incumple la política, 

Cuando intenta continuar, 

Entonces el sistema muestra el mensaje indicando la regla incumplida. 

**CV-24 – Código válido** 

Dado una identificación válida, 

Cuando el usuario ingresa un código correcto, 

Entonces el sistema responde con el comportamiento definido por las reglas de negocio del módulo correspondiente. 

**CV-25 – Código incorrecto o expirado** 

Dado un código inválido, 

Cuando intenta validarlo, 

Entonces el sistema muestra “Error: código incorrecto o expirado”. 

**CV-26 – Cuenta duplicada** 

Dado un {propietario | residente | miembro} con cuenta existente en el sistema, Cuando el usuario intenta crear una cuenta nueva 

Entonces el sistema muestra “Error: cuenta ya existe” y no guarda el registro. 

**CV-27 – Cuenta ya inactiva** 

Dado un {propietario | residente | miembro} cuyo estado ya es inactivo, Cuando se intenta bloquear nuevamente, 

Entonces el sistema muestra “Advertencia: la cuenta se encuentra inactiva”. 

**CV-28 – Visualización previa de datos** 

Dado una identificación válida de {propietario | residente | miembro}, 

Cuando el usuario la ingresa, 

Entonces el sistema visualiza los datos del {propietario | residente | miembro} para confirmar identidad antes del bloqueo. 

**CV-29 – Inicio de sesión con cuenta bloqueada** 

Dado una cuenta de {propietario | residente | miembro} marcada como bloqueada, Cuando el usuario intenta iniciar sesión, 

Entonces el sistema muestra: “Error: cuenta bloqueada”. 

**CV-30 – Intento de generar QR desde una cuenta eliminada** Dado una cuenta de {propietario | residente | miembro} bloqueada, Cuando intenta generar un código QR, 

Entonces el sistema muestra: “Error: cuenta bloqueada”. 

**CV-31 – Acceso a funcionalidades privadas** 

Dado una cuenta de {propietario | residente | miembro} bloqueada, 

Cuando intenta acceder a opciones del sistema que requieren autenticación, Entonces el sistema muestra: “Error: cuenta bloqueada”. 

**CV-32 – Uso de cuenta bloqueada como referencia** 

Dado una cuenta de {propietario | residente | miembro} bloqueada, Cuando se intenta utilizar para cualquier acción dependiente, 

Entonces el sistema muestra: “Error: cuenta bloqueada”. 

**CV-XX Registro en bitácora** 

Dado un proceso del sistema ejecutado de manera exitosa que genera una modificación en un registro (de una {persona | vivienda | vehículo | acceso | propietario | residente}, según corresponda), 

Cuando el proceso finaliza, 

Entonces el sistema registra en la bitácora la fecha, hora, tipo de operación, 

el valor anterior y el valor actualizado de los datos modificados. 

2. **Requerimientos no funcionales** 

*3.2.1  Reglas de validación y formato de datos* 

Las siguientes reglas definen los formatos y restricciones aplicables a todos los campos del sistema: 



|**Campo** |**Tipo de dato** |**Formato / Longitud** |**Validación / Restricción** |
| - | - | :- | :- |
|Identificación |Numérico |10 dígitos |Solo números, sin guiones |
|Correo electrónico |Texto |Hasta 100 caracteres |Formato usuario@dominio.com (RFC 5322) |
|Fecha de nacimiento |Fecha |DD-MM-YYYY |Debe ser anterior al año actual |
|Celular |Numérico |10 dígitos |Formato 09XXXXXXXX |
|Dirección alternativa |Texto |Hasta 120 caracteres |Opcional |

4. **Restricciones** 

El sistema debe operar bajo políticas internas de la urbanización, utilizando formatos estandarizados de datos y protocolos de seguridad. Solo usuarios autorizados podrán realizar modificaciones. 

5. **Apéndices** 

Información adicional, catálogos de datos o definiciones complementarias que respalden los requerimientos. 

**Apéndice A – Catálogo de datos del sistema** 

Este apéndice lista todos los campos relevantes con su tipo de dato, longitud, validación y obligatoriedad. 

**Listado General de Requerimientos Funcionales** 
