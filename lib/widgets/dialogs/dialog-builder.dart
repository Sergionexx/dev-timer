import 'package:flutter/material.dart';

generateDialog(BuildContext context, dynamic classDialog, double heightCard) {
  return showDialog(
    context: context,
    barrierDismissible:
        false, // Evita que el diálogo se cierre al presionar fuera de él
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          // Aquí puedes agregar la lógica que desees ejecutar antes de cerrar el diálogo
          return false; // Devuelve false para evitar que se cierre el diálogo
        },
        child: Center(
          // Centrar el diálogo en la pantalla
          child: Stack(
            children: [
              // Contenedor para centrar verticalmente
              Center(
                child: SizedBox(
                  width: 500, // Define el ancho deseado
                  height: heightCard, // Define el alto deseado
                  child: Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10), // Definir bordes redondos
                      color: Colors
                          .white, // Cambiar color de fondo si es necesario
                    ),
                    child: classDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
