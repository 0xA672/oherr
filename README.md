# oherr

**A Rust-style `Result` type for Ada. (Oh, error!)**

[![License](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue)](./LICENSE)
[![Ada](https://img.shields.io/badge/Language-Ada-00a2e1?logo=Ada)](https://www.ada-lang.io/)

# Usage – Instantiation

Because `Oh_Err` is generic, you must instantiate it with your concrete types first.

```ada
with Oh_Err;

package Integer_Result is new Oh_Err
  (Success_Type => Integer,
   Error_Type   => String);

-- Now use Integer_Result.Result, Integer_Result.Ok, etc.
```

For readability,you can rename this instantiation:

```ada
package Result_Int is new Oh_Err (Integer, String);
use Result_Int;
```

## Quick Start

```ada
with Ada.Text_IO; use Ada.Text_IO;
with Oh_Err;

procedure Demo is
   package Int_Result is new Oh_Err (Integer, String);
   use Int_Result;

   function Parse_Int (S : String) return Result is
   begin
      return Ok (Integer'Value (S));
   exception
      when others =>
         return Err ("Not a valid integer");
   end Parse_Int;

   function Double_If_Even (N : Integer) return Result is
   begin
      if N mod 2 = 0 then
         return Ok (N * 2);
      else
         return Err ("Only even numbers allowed");
      end if;
   end Double_If_Even;

   R : Result := Parse_Int ("4");
begin
   -- Chain with And_Then (Success_Binder)
   R := R.And_Then (Double_If_Even'Access);

   -- Unwrap or handle error
   Put_Line ("Value: " & Integer'Image (R.Unwrap));
exception
   when Unwrap_Error =>
      Put_Line ("Something went wrong!");
end Demo;
```

# API Reference

## Generic formal parameters

```ada
generic
   type Success_Type is private;
   type Error_Type (<>) is private;
package Oh_Err is ...
```

Your chosen types become `Success_Type` and `Error_Type` inside the instantiation.
> `Error_Type` can be indefinite (e.g., `String`), thanks to the `(<>)` marker.

## Main types

| Name | Description |
|------|-------------|
| `Result` | A discriminated record that holds either a `Success_Type` value (when `Success = True`) or an `Error_Type` error (when `Success = False`). Constructed via `Ok` or `Err`. |
| `Success_Mapper` | Access type: `access function (Value : Success_Type) return Success_Type` |
| `Success_Binder` | Access type: `access function (Value : Success_Type) return Result` |

## Constructors

**`function Ok (Value : Success_Type) return Result`**  
Create a successful `Result` containing `Value`.

**`function Err (Error : Error_Type) return Result`**  
Create an error `Result` containing `Error`.

## Checkers

**`function Is_Ok (R : Result) return Boolean`**  
Returns `True` if `R` holds a success value.

**`function Is_Err (R : Result) return Boolean`**  
Returns `True` if `R` holds an error.

## Extracting values

**`function Unwrap (R : Result) return Success_Type`**  
Returns the contained success value.  
Raises `Unwrap_Error` if `R` is an error.

**`function Unwrap_Or (R : Result; Default : Success_Type) return Success_Type`**  
Returns the success value if `Is_Ok(R)`, otherwise returns `Default`.

## Combinators

**`function Map (R : Result; F : Success_Mapper) return Result`**  
If `R` is success, applies `F` to the value and returns `Ok(F(Value))`.  
Otherwise propagates the error unchanged.

**`function And_Then (R : Result; F : Success_Binder) return Result`**  
Chains a fallible operation. If `R` is success, returns `F(Value)`.  
If `R` is an error, returns the error unchanged (short-circuit).

**`function Or_Else (R : Result; Default : Result) return Result`**  
If `R` is success, returns `R`. Otherwise returns `Default`.

**`procedure Match (R : Result; Ok_Handler : access procedure (Value : Success_Type); Err_Handler : access procedure (Error : Error_Type))`**  
Pattern matching on the result.  
Calls `Ok_Handler` with the success value, or `Err_Handler` with the error.

## Exception

- **`Unwrap_Error`** – Raised by `Unwrap` when called on an `Err` result.  
  All other operations (`Map`, `And_Then`, `Or_Else`, `Match`) are exception‑free.

## License

Licensed under either of

- MIT license
- Apache License, Version 2.0

at your option.
