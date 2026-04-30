pragma Style_Checks (Off);

package body Oh_Err is

   function Ok (Value : Success_Type) return Result is
   begin
      return (Success => True, Value => Value);
   end Ok;

   function Err (Error : Error_Type) return Result is
   begin
      return (Success => False, Err => Error);
   end Err;

   function Is_Ok (R : Result) return Boolean is
   begin
      return R.Success;
   end Is_Ok;

   function Is_Err (R : Result) return Boolean is
   begin
      return not R.Success;
   end Is_Err;

   function Unwrap (R : Result) return Success_Type is
   begin
      if R.Success then
         return R.Value;
      else
         raise Unwrap_Error;
      end if;
   end Unwrap;

   function Unwrap_Or (R : Result; Default : Success_Type) return Success_Type is
   begin
      if R.Success then
         return R.Value;
      else
         return Default;
      end if;
   end Unwrap_Or;

   function Map (R : Result; F : Success_Mapper) return Result is
   begin
      if R.Success then
         return Ok(F(R.Value));
      else
         return R;
      end if;
   end Map;

   function And_Then (R : Result; F : Success_Binder) return Result is
   begin
      if R.Success then
         return F(R.Value);
      else
         return R;
      end if;
   end And_Then;

   function Or_Else (R : Result; Default : Result) return Result is
   begin
      if R.Success then
         return R;
      else
         return Default;
      end if;
   end Or_Else;

   procedure Match (R          : Result;
                    Ok_Handler : access procedure (Value : Success_Type);
                    Err_Handler: access procedure (Error : Error_Type)) is
   begin
      if R.Success then
         Ok_Handler(R.Value);
      else
         Err_Handler(R.Err);
      end if;
   end Match;

end Oh_Err;
