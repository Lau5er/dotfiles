{ pkgs-unstable, vscode-extensions, ... }:

{
  programs.vscode.profiles.default.extensions =
    with vscode-extensions.vscode-marketplace; [
      # STM32 Extension Pack + alle Abhängigkeiten
      stmicroelectronics.stm32-vscode-extension
      stmicroelectronics.stm32cube-ide-core
      stmicroelectronics.stm32cube-ide-bundles-manager
      stmicroelectronics.stm32cube-ide-build-cmake
      stmicroelectronics.stm32cube-ide-build-analyzer
      stmicroelectronics.stm32cube-ide-project-manager
      stmicroelectronics.stm32cube-ide-debug-core
      stmicroelectronics.stm32cube-ide-debug-generic-gdbserver
      stmicroelectronics.stm32cube-ide-debug-stlink-gdbserver
      stmicroelectronics.stm32cube-ide-debug-jlink-gdbserver
      stmicroelectronics.stm32cube-ide-rtos
      stmicroelectronics.stm32cube-ide-registers
      stmicroelectronics.stm32cube-ide-clangd
      eclipse-cdt.memory-inspector
      eclipse-cdt.serial-monitor
    ] ++ (with pkgs-unstable.vscode-extensions; [
      ms-vscode.cmake-tools
    ]);
}
