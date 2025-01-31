defmodule FixNasmSyntax do

  def convert_to_nasm(asm_file) do
    asm_code = File.read!(asm_file)

    fixed_code =
      asm_code
      |> String.replace(~r/\.file\s+".*"\n/, "")  # Eliminar la l�nea .file
      |> String.replace(~r/\.text/, "section .text")  # Convertir .text a "section .text"
      |> String.replace(~r/\.section\s+\.rodata.*$/, "section .rodata")  # Convertir .section .rodata
      |> String.replace(~r/\.globl\s+main/, "global _start")  # Cambiar main a _start para NASM
      |> String.replace(~r/main:/, "_start:")  # Cambiar la etiqueta de main a _start
      |> String.replace(~r/\.type\s+\w+,\s*@function/, "")  # Eliminar la directiva de tipo
      |> String.replace(~r/\.size\s+\w+,.*$/, "")  # Eliminar la directiva de tama�o
      |> String.replace(~r/\n\.(?:cfi_.*|ident.*)\n/, "")  # Eliminar directivas CFI y .ident
      |> String.replace(~r/\.section\s+\.note.GNU-stack.*$/, "")  # Eliminar la secci�n GNU-stack
      |> String.replace(~r/\.p2align\s+\d+/ , "")  # Eliminar directiva .p2align
      |> String.replace(~r/\.LC\d+:\n/, "")  # Eliminar etiquetas como .LC0, .LC1...
      |> String.replace(~r/\.string\s+"([^"]+)"/, "db '\\1', 0")  # Convertir .string a db para NASM
      |> String.replace(~r/\s+\(.*\)/, "")  # Eliminar partes de las instrucciones que no son necesarias para NASM
      |> String.replace(~r/\s+@PLT/, "")  # Eliminar @PLT en las llamadas
      |> String.replace(~r/xorl\s+%eax,\s+%eax/, "xor eax, eax")  # Sintaxis de NASM para xor
      |> String.replace(~r/(\w+)\s+%rsp/, "sub rsp, 8")  # Convierte las instrucciones para rsp
      |> String.replace(~r/(\w+)\s+\$8,(\s+%rsp)/, "add rsp, 8")  # A�adir rsp para NASM


    File.write!(asm_file, fixed_code)
  end


end
