-- Function: public.makegrid_2d(GEOMETRY, NUMERIC, INTEGER)

-- DROP FUNCTION public.makegrid_2d(GEOMETRY, NUMERIC, integer);

CREATE OR REPLACE FUNCTION public.makegrid_2d(bound_polygon GEOMETRY, grid_step NUMERIC, srid INTEGER)
  RETURNS table (cell_geom GEOMETRY, cell_centroid_geom GEOMETRY, cell_x INTEGER, cell_y INTEGER) AS 
$BODY$
DECLARE
  BoundM public.GEOMETRY; 
  Xmin DOUBLE PRECISION;
  Xmax DOUBLE PRECISION;
  Ymax DOUBLE PRECISION;
  AgeomD GEOMETRY;
  AgeogM GEOGRAPHY;
  BYgeomD GEOMETRY;
  BYgeogM GEOGRAPHY;
  YfactorM DOUBLE PRECISION;
  BXgeomD GEOMETRY;
  BXgeogM GEOGRAPHY;
  XfactorM DOUBLE PRECISION;
  X DOUBLE PRECISION;
  Y DOUBLE PRECISION;
  XLeftArray INTEGER ARRAY;
  YTopArray INTEGER ARRAY;
  XRightArray INTEGER ARRAY;
  YBottomArray INTEGER ARRAY;
  sectors public.GEOMETRY[];
  sectorsCentroid public.GEOMETRY[];
  sectorsX INTEGER ARRAY;
  sectorsY INTEGER ARRAY;
  Xdistance DOUBLE PRECISION;
  XdistanceDegrees DOUBLE PRECISION;
  XdistanceMeters DOUBLE PRECISION;
  Ydistance DOUBLE PRECISION;
  YdistanceDegrees DOUBLE PRECISION;
  YdistanceMeters DOUBLE PRECISION;
  i INTEGER;
  iX INTEGER;
  iY INTEGER;
BEGIN
  BoundM := $1; 
  Xmin := ROUND(CAST(ST_XMin(BoundM) as NUMERIC),5);
  Xmax := ST_XMax(BoundM);
  Ymax := ST_YMax(BoundM);
  Y := ROUND(CAST(ST_YMin(BoundM) as NUMERIC),5); --current sector's corner coordinate
  iY := 1;
  i := -1;
  <<yloop>>
  LOOP
    IF (Y > Ymax) THEN --Better if generating polygons exceeds bound for one step. You always can crop the result. But if not you may get not quite correct data for outbound polygons (if you calculate frequency per a sector e.g.)
      EXIT;
    END IF;
    X := Xmin;
    iX := 1;
    AgeomD := ST_GeomFromText('POINT('||X||' '||Y||')', $3);
    BYgeomD := ST_GeomFromText('POINT('||X||' '||Y+0.01||')', $3);
    AgeogM := ST_GeographyFromText('SRID='||$3||';POINT('||X||' '||Y||')');
    BYgeogM := ST_GeographyFromText('SRID='||$3||';POINT('||X||' '||Y+0.01||')');
    YDistanceDegrees := ST_Distance(AgeomD, BYgeomD);
    YDistanceMeters := ST_Distance(AgeogM, BYgeogM);
    YfactorM := $2 / YDistanceMeters; 
    YDistance := ROUND(CAST(YDistanceDegrees * YfactorM as numeric), 7); 
    --RAISE unique_violation USING MESSAGE = 'distance: ' || YDistance; --for debug purpose
    <<xloop>>
    LOOP
      IF (X > Xmax) THEN
        EXIT;
      END IF;
      i := i + 1;
      AgeomD := ST_GeomFromText('POINT('||X||' '||Y||')', $3);
      BXgeomD := ST_GeomFromText('POINT('||X+0.01||' '||Y||')', $3);
      AgeogM := ST_GeographyFromText('SRID='||$3||';POINT('||X||' '||Y||')');
      BXgeogM := ST_GeographyFromText('SRID='||$3||';POINT('||X+0.01||' '||Y||')');
      XDistanceDegrees := ST_Distance(AgeomD, BXgeomD);
      XDistanceMeters := ST_Distance(AgeogM, BXgeogM);
      XfactorM := $2 / XDistanceMeters;
      XDistance := ROUND(CAST(XDistanceDegrees * XfactorM as NUMERIC), 7);
      sectors[i] := ST_GeomFromText('POLYGON(('||X||' '||Y||', '||(X+XDistance)||' '||Y||', '||(X+XDistance)||' '||(Y+YDistance)||', '||X||' '||(Y+YDistance)||', '||X||' '||Y||'))', $3);
      sectorsCentroid[i] := ST_Centroid(sectors[i] );
      sectorsX[i] := iX;
      sectorsY[i] := iY;
      RETURN QUERY SELECT sectors[i], sectorsCentroid[i], sectorsX[i] , sectorsY[i] ; 
      X := X + XDistance;
      iX := iX + 1;
    END LOOP xloop;
    Y := Y + YDistance;
    iY := iY + 1;
  END LOOP yloop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.makegrid_2d(GEOMETRY, NUMERIC, INTEGER)
  OWNER TO postgres;
