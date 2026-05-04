with Ada.Containers.Indefinite_Holders;

generic
   type Success_Type is private;
   type Error_Type (<>) is private;
package Oh_Err is

   type Result is private;

   Unwrap_Error : exception;

   type Success_Mapper is access function (Value : Success_Type) return Success_Type;
   type Success_Binder is access function (Value : Success_Type) return Result;

   function Ok  (Value : Success_Type) return Result;
   function Err (Error : Error_Type)   return Result;
   function Is_Ok  (R : Result) return Boolean;
   function Is_Err (R : Result) return Boolean;
   function Unwrap    (R : Result) return Success_Type;
   function Unwrap_Or (R : Result; Default : Success_Type) return Success_Type;
   function Map      (R : Result; F : Success_Mapper) return Result;
   function And_Then (R : Result; F : Success_Binder) return Result;
   function Or_Else  (R : Result; Default : Result) return Result;

   procedure Match (R          : Result;
                    Ok_Handler : access procedure (Value : Success_Type);
                    Err_Handler: access procedure (Error : Error_Type));

private
   package Error_Holder is new Ada.Containers.Indefinite_Holders (Error_Type);

   type Result (Success : Boolean := True) is record
      case Success is
         when True  => Value : Success_Type;
         when False => Err   : Error_Holder.Holder;
      end case;
   end record;
end Oh_Err;
