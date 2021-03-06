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

with CL.API;
with CL.Enumerations;
with CL.Helpers;

package body CL.Queueing.Memory_Objects is
   Element_Bytes : constant Size := Element'Size / System.Storage_Unit;

   procedure Read_Buffer (Target_Queue : Command_Queues.Queue'Class;
                          Buffer       : Memory.Buffers.Buffer'Class;
                          Blocking     : Boolean;
                          Offset       : Size;
                          Destination  : Element_List;
                          Ready        : out Events.Event;
                          Wait_For     : Events.Event_List := Events.No_Events) is

      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Read_Buffer
              (CL_Object (Target_Queue).Location,
               CL_Object (Buffer).Location,
               CL.Bool (Blocking), Offset,
               Destination'Length * Element_Bytes,
               Destination (Destination'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Read_Buffer
           (CL_Object (Target_Queue).Location,
            CL_Object (Buffer).Location,
            CL.Bool (Blocking), Offset,
            Destination'Length * Element_Bytes,
            Destination (Destination'First)'Address,
            0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                           Location => Ret_Event);
   end Read_Buffer;
   
   procedure Write_Buffer (Target_Queue : Command_Queues.Queue'Class;
                           Buffer       : Memory.Buffers.Buffer'Class;
                           Blocking     : Boolean;
                           Offset       : Size;
                           Source       : Element_List;
                           Ready        : out Events.Event;
                           Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Write_Buffer
              (CL_Object (Target_Queue).Location,
               CL_Object (Buffer).Location,
               CL.Bool (Blocking), Offset,
               Source'Length * Element_Bytes,
               Source (Source'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Write_Buffer
              (CL_Object (Target_Queue).Location,
               CL_Object (Buffer).Location,
               CL.Bool (Blocking), Offset,
               Source'Length * Element_Bytes,
               Source (Source'First)'Address,
               0, null, Ret_Event'Unchecked_Access);
      end if;

      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Write_Buffer;

   procedure Copy_Buffer (Target_Queue  : Command_Queues.Queue'Class;
                          Source        : Memory.Buffers.Buffer'Class;
                          Destination   : Memory.Buffers.Buffer'Class;
                          Source_Offset : Size;
                          Dest_Offset   : Size;
                          Num_Elements  : Size;
                          Ready         : out Events.Event;
                          Wait_For      : Events.Event_List := Events.No_Events) is
      Raw_List  : Address_List := Raw_Event_List (Wait_For);
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      Error := API.Enqueue_Copy_Buffer (CL_Object (Target_Queue).Location,
                                        CL_Object (Source).Location,
                                        CL_Object (Destination).Location,
                                        Source_Offset, Dest_Offset, Num_Elements,
                                        Raw_List'Length,
                                        Raw_List (1)'Unchecked_Access,
                                        Ret_Event'Unchecked_Access);
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Copy_Buffer;

   procedure Read_Image2D (Target_Queue : Command_Queues.Queue'Class;
                           Image        : Memory.Images.Image2D'Class;
                           Blocking     : Boolean;
                           Origin       : Size_Vector2D;
                           Region       : Size_Vector2D;
                           Row_Pitch    : Size;
                           Destination  : Element_List;
                           Ready        : out Events.Event;
                           Wait_For     : Events.Event_List := Events.No_Events) is

      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
      Origin_3D : Size_Vector3D := (1 => Origin (1), 2 => Origin (2), 3 => 0);
      Region_3D : Size_Vector3D := (1 => Region (1), 2 => Region (2), 3 => 1);
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Read_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin_3D (1)'Unchecked_Access,
               Region_3D (1)'Unchecked_Access,
               Row_Pitch, 0,
               Destination (Destination'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Read_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin_3D (1)'Unchecked_Access,
               Region_3D (1)'Unchecked_Access,
               Row_Pitch, 0,
               Destination (Destination'First)'Address,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Read_Image2D;

   procedure Read_Image3D (Target_Queue : Command_Queues.Queue'Class;
                           Image        : Memory.Images.Image3D'Class;
                           Blocking     : Boolean;
                           Origin       : Size_Vector3D;
                           Region       : Size_Vector3D;
                           Row_Pitch    : Size;
                           Slice_Pitch  : Size;
                           Destination  : Element_List;
                           Ready        : out Events.Event;
                           Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Read_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking), Origin (1)'Access,
               Region (1)'Access,
               Row_Pitch, Slice_Pitch,
               Destination (Destination'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Read_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking), Origin (1)'Access,
               Region (1)'Access,
               Row_Pitch, Slice_Pitch,
               Destination (Destination'First)'Address,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Read_Image3D;

   procedure Write_Image2D (Target_Queue : Command_Queues.Queue'Class;
                            Image        : Memory.Images.Image2D'Class;
                            Blocking     : Boolean;
                            Origin       : Size_Vector2D;
                            Region       : Size_Vector2D;
                            Row_Pitch    : Size;
                            Source       : Element_List;
                            Ready        : out Events.Event;
                            Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
      Origin_3D : Size_Vector3D := (1 => Origin (1), 2 => Origin (2), 3 => 0);
      Region_3D : Size_Vector3D := (1 => Region (1), 2 => Region (2), 3 => 1);
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Write_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin_3D (1)'Access,
               Region_3D (1)'Access,
               Row_Pitch, 0,
               Source (Source'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Write_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin_3D (1)'Access,
               Region_3D (1)'Access,
               Row_Pitch, 0,
               Source (Source'First)'Address,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Write_Image2D;

   procedure Write_Image3D (Target_Queue : Command_Queues.Queue'Class;
                            Image        : Memory.Images.Image3D'Class;
                            Blocking     : Boolean;
                            Origin       : Size_Vector3D;
                            Region       : Size_Vector3D;
                            Row_Pitch    : Size;
                            Slice_Pitch  : Size;
                            Source       : Element_List;
                            Ready        : out Events.Event;
                            Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Write_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin (1)'Access,
               Region (1)'Access,
               Row_Pitch, Slice_Pitch,
               Source (Source'First)'Address,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Write_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Image).Location,
               CL.Bool (Blocking),
               Origin (1)'Access,
               Region (1)'Access,
               Row_Pitch, Slice_Pitch,
               Source (Source'First)'Address,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Write_Image3D;

   procedure Copy_Image2D (Target_Queue : Command_Queues.Queue'Class;
                           Source       : Memory.Images.Image2D'Class;
                           Destination  : Memory.Images.Image2D'Class;
                           Src_Origin   : Size_Vector2D;
                           Dest_Origin  : Size_Vector2D;
                           Region       : Size_Vector2D;
                           Ready        : out Events.Event;
                           Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
      Src_Origin_3D : Size_Vector3D := (1 => Src_Origin (1),
                                        2 => Src_Origin (2), 3 => 0);
      Dest_Origin_3D : Size_Vector3D := (1 => Dest_Origin (1),
                                         2 => Dest_Origin (2), 3 => 0);
      Region_3D : Size_Vector3D := (1 => Region (1), 2 => Region (2), 3 => 1);
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Copy_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Source).Location,
               CL_Object (Destination).Location,
               Src_Origin_3D (1)'Access,
               Dest_Origin_3D (1)'Access,
               Region_3D (1)'Access,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Copy_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Source).Location,
               CL_Object (Destination).Location,
               Src_Origin_3D (1)'Access,
               Dest_Origin_3D (1)'Access,
               Region_3D (1)'Access,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Copy_Image2D;

   procedure Copy_Image3D (Target_Queue : Command_Queues.Queue'Class;
                           Source       : Memory.Images.Image3D'Class;
                           Destination  : Memory.Images.Image3D'Class;
                           Src_Origin   : Size_Vector3D;
                           Dest_Origin  : Size_Vector3D;
                           Region       : Size_Vector3D;
                           Ready        : out Events.Event;
                           Wait_For     : Events.Event_List := Events.No_Events) is
      Error     : Enumerations.Error_Code;
      Ret_Event : aliased System.Address;
   begin
      if Wait_For'Length > 0 then
         declare
            Raw_List  : Address_List := Raw_Event_List (Wait_For);
         begin
            Error := API.Enqueue_Copy_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Source).Location,
               CL_Object (Destination).Location,
               Src_Origin (1)'Access,
               Dest_Origin (1)'Access,
               Region (1)'Access,
               Raw_List'Length,
               Raw_List (1)'Unchecked_Access,
               Ret_Event'Unchecked_Access);
         end;
      else
         Error := API.Enqueue_Copy_Image
              (CL_Object (Target_Queue).Location,
               CL_Object (Source).Location,
               CL_Object (Destination).Location,
               Src_Origin (1)'Access,
               Dest_Origin (1)'Access,
               Region (1)'Access,
               0, null, Ret_Event'Unchecked_Access);
      end if;
      Helpers.Error_Handler (Error);
      Ready := Events.Event'(Ada.Finalization.Controlled with
                             Location => Ret_Event);
   end Copy_Image3D;
end CL.Queueing.Memory_Objects;
