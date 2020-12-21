CREATE OR REPLACE FUNCTION public.setze_lastupdate_firstdate()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
 DECLARE
     lastupdate_spalte varchar;
     lastupdate_benutzer_spalte varchar;
     firstdate_spalte varchar;
     firstdate_benutzer_spalte varchar;
 BEGIN
     IF tg_op = 'UPDATE' THEN
        NEW.bgdi_modified           := current_timestamp;
        NEW.bgdi_modified_by  := current_user;
        return NEW;
     END IF;

     IF tg_op = 'INSERT' THEN
        NEW.bgdi_created              := current_timestamp;
        NEW.bgdi_created_by           := current_user;
        return NEW;
     END IF;
 END;
 $function$