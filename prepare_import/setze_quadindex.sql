CREATE OR REPLACE FUNCTION public.setze_quadindex()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
 DECLARE
     hstore hstore := hstore(NEW);
     quadindex text;
 BEGIN
     IF tg_op = 'UPDATE' OR tg_op = 'INSERT' THEN
        quadindex :=  quadindex(hstore -> TG_ARGV[1]);
        NEW := NEW #= hstore(TG_ARGV[0], quadindex);
        RETURN NEW;
     END IF;
 END;
 $function$