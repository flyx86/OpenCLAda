--------------------------------------------------------------------------------
-- Copyright (c) 2013, Felix Krause <contact@flyx.org>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--------------------------------------------------------------------------------

with Ada.Finalization;
with Interfaces.C;
with System;

private with Interfaces.C.Pointers;

package CL is
   pragma Preelaborate (CL);

   -----------------------------------------------------------------------------
   --  OpenCL scalar types that are available
   --  in the OpenCL C programming language
   -----------------------------------------------------------------------------

   --  signed integer types
   type Char  is new Interfaces.Integer_8;
   type Short is new Interfaces.Integer_16;
   type Int   is new Interfaces.Integer_32;
   type Long  is new Interfaces.Integer_64;

   for Char'Size  use 8;
   for Short'Size use 16;
   for Int'Size   use 32;
   for Long'Size  use 64;

   --  unsigned integer types
   type UChar  is new Interfaces.Unsigned_8;
   type UShort is new Interfaces.Unsigned_16;
   type UInt   is new Interfaces.Unsigned_32;
   type ULong  is new Interfaces.Unsigned_64;

   for UChar'Size  use 8;
   for UShort'Size use 16;
   for UInt'Size   use 32;
   for ULong'Size  use 64;

   --  floating point types
   type Float is new Standard.Float;
   type Half  is new Short;
   for Half'Size use Short'Size;

   -- ranges of vector types
   subtype Range2  is Natural range 0 .. 1;
   subtype Range3  is Natural range 0 .. 2;
   subtype Range4  is Natural range 0 .. 3;
   subtype Range8  is Natural range 0 .. 7;
   subtype Range16 is Natural range 0 .. 15;
   
   
   -- Mainly needed in order to have a single interface for
   -- converting numeric values to string when instantiating
   -- generic packages like Vector_Operations. ('Img cannot
   -- be used directly because it takes both integer and floating
   -- point types, and there is no common supertype that supports
   -- 'Img)
   function To_String (Value : Char)     return String;
   function To_String (Value : Short)    return String;
   function To_String (Value : Int)      return String;
   function To_String (Value : Long)     return String;
   function To_String (Value : UChar)    return String;
   function To_String (Value : UShort)   return String;
   function To_String (Value : UInt)     return String;
   function To_String (Value : ULong)    return String;
   function To_String (Value : CL.Float) return String;
   pragma Inline (To_String);
   
   -- Float types should be compared with a small epsilon value to
   -- compensate rounding errors and such.
   generic
      Epsilon : Float;
   function Float_Equals (Left, Right : Float) return Boolean;
   
   -----------------------------------------------------------------------------
   --  Types used by this API
   -----------------------------------------------------------------------------
   type Size is new Interfaces.C.size_t;

   type Size_List is array (Positive range <>) of aliased Size;

   type Char_List is array (Positive range <>) of
     aliased Interfaces.C.unsigned_char;

   --  only Runtime_Objects implement Adjust and Finalize, but as multiple
   --  inheritance isn't possible, we have to derive CL_Object from Controlled
   type CL_Object is abstract new Ada.Finalization.Controlled with private;

   function "=" (Left, Right : CL_Object) return Boolean;

   type Runtime_Object is abstract new CL_Object with private;

   function Initialized (Object : Runtime_Object) return Boolean;

   function Reference_Count (Source : Runtime_Object) return UInt is abstract;
   
   function Raw (Source : Runtime_Object) return System.Address;

   -----------------------------------------------------------------------------
   --  Exceptions
   -----------------------------------------------------------------------------
   Invalid_Global_Work_Size        : exception;
   Invalid_Mip_Level               : exception;
   Invalid_Buffer_Size             : exception;
   Invalid_GL_Object               : exception;
   Invalid_Operation               : exception;
   Invalid_Event                   : exception;
   Invalid_Event_Wait_List         : exception;
   Invalid_Global_Offset           : exception;
   Invalid_Work_Item_Size          : exception;
   Invalid_Work_Group_Size         : exception;
   Invalid_Work_Dimension          : exception;
   Invalid_Kernel_Args             : exception;
   Invalid_Arg_Size                : exception;
   Invalid_Arg_Value               : exception;
   Invalid_Arg_Index               : exception;
   Invalid_Kernel                  : exception;
   Invalid_Kernel_Definition       : exception;
   Invalid_Kernel_Name             : exception;
   Invalid_Program_Executable      : exception;
   Invalid_Program                 : exception;
   Invalid_Build_Options           : exception;
   Invalid_Binary                  : exception;
   Invalid_Sampler                 : exception;
   Invalid_Image_Size              : exception;
   Invalid_Image_Format_Descriptor : exception;
   Invalid_Mem_Object              : exception;
   Invalid_Host_Ptr                : exception;
   Invalid_Command_Queue           : exception;
   Invalid_Queue_Properties        : exception;
   Invalid_Context                 : exception;
   Invalid_Device                  : exception;
   Invalid_Platform                : exception;
   Invalid_Device_Type             : exception;
   Invalid_Value                   : exception;

   Kernel_Arg_Info_Not_Available   : exception;
   Device_Partition_Failed         : exception;
   Link_Program_Failure            : exception;
   Linker_Not_Available            : exception;
   Compile_Program_Failure         : exception;
   Exec_Status_Error_For_Events_In_Wait_List : exception;
   Misaligned_Sub_Buffer_Offset    : exception;
   Map_Failure                     : exception;
   Build_Program_Failure           : exception;
   Image_Format_Not_Supported      : exception;
   Image_Format_Mismatch           : exception;
   Mem_Copy_Overlap                : exception;
   Profiling_Info_Not_Available    : exception;
   Out_Of_Host_Memory              : exception;
   Out_Of_Resources                : exception;
   Mem_Object_Allocation_Failure   : exception;
   Compiler_Not_Available          : exception;
   Device_Not_Available            : exception;
   Device_Not_Found                : exception;
   Internal_Error                  : exception;
   Invalid_Local_Work_Size         : exception;

private
   type CL_Object is abstract new Ada.Finalization.Controlled with record
      Location : System.Address := System.Null_Address;
   end record;

   type Runtime_Object is abstract new CL_Object with null record;

   -----------------------------------------------------------------------------
   --  Types used with C calls
   -----------------------------------------------------------------------------
   type Size_Ptr     is access all Size;
   type UInt_Ptr     is access all UInt;
   type Address_Ptr  is access all System.Address;
   type Address_List is array (Positive range <>) of aliased System.Address;

   pragma Convention (C, Size_Ptr);
   pragma Convention (C, UInt_Ptr);
   pragma Convention (C, Address_Ptr);
   pragma Convention (C, Address_List);

   type Bool is new Boolean;
   for Bool use (False => 0, True => 1);
   for Bool'Size use UInt'Size;

   type Bitfield is new ULong;
   for Bitfield'Size use ULong'Size;

   package IFC renames Interfaces.C;

   package C_Chars is
     new Interfaces.C.Pointers (Index              => Positive,
                                Element            => IFC.unsigned_char,
                                Element_Array      => Char_List,
                                Default_Terminator => 0);
end CL;

