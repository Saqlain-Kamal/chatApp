import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onTap,
    required this.isloading,
    required this.text,
    super.key,
  });
  final void Function()? onTap;
  final bool isloading;
  final String text;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        width: double.infinity,
        height: 50,
        child: Center(
            child: isloading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  )),
      ),
    );
  }
}
