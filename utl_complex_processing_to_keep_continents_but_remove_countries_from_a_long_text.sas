Somewhat complex processing to keep continents but remove countries from a long text.

Two solutions

see
https://goo.gl/iPdoH6
https://communities.sas.com/t5/Base-SAS-Programming/Can-I-use-TRANWRD-to-replace-multiple-variable-values-with-space/m-p/415280

Warren Kuhfeld profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/16777

I have this text and I need to keep continents and remove countries

INPUT
=====

   WORK.HAVE total obs=2

     TEXT                                                          |      RULES (remove countries)
                                                                   |
     North America Venezuela Mexico and Antartica are continents.  |    North America Antartica are continents.
     The Artic Sweden Norway is a tundra region                    |    The Artic is a tundra region.
                                                                   |

   WORK.HAV2ND total obs=75

     REMOVE_COUNTRY

     USA
     Afghanistan
     Algeria
     Angola
     Argentina
     Australia
     Austria
    ...

PROCESS  (quite elegant)
========================

  SOLUTION 1

     data want;
        set hav1st;    * text is retained because pint is used below - nice;
        do i = 1 to n;
           set hav2nd point=i nobs=n;
           text = compbl(tranwrd(text, trim(remove_country),' '));  * repeatedly works on text;
        end;
        keep text;
     run;quit;
  SOLUTION 1

     data want;

       if _n_=0 then do;
         %let rc=%sysfunc(dosubl('
           proc sql;
              select remove_country into :rems separated by "|"
              from hav2nd
           ;quit;
         '));
        end;

        set hav1st;
        rc0=prxparse("s/&rems.//");
        call prxchange(rc0,-1,text,text);
        text=compbl(text);
     run;quit;

OUTPUT
======

WORK.WANT total obs=2

                  TEXT

 North America Antartica are continents.
 The Artic is a tundra region.

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data hav1st;
 input;
 text=_infile_;
cards4;
North America Venezuela Mexico Antartica are continents.
The Artic Sweden Norway is a tundra region.
;;;;
run;quit;

data hav2nd(keep=remove_country);
   informat remove_country $44.;
   input remove_country  $ ;
cards4;
USA
Afghanistan
Algeria
Angola
Argentina
Australia
Austria
Bangladesh
Belgium
Brazil
Bulgaria
Burma
Cameroon
Canada
Chile
China
Taiwan
Colombia
Cuba
Czechoslovakia
Ecuador
Egypt
Ethiopia
France
German Dem Rep
Germany, Fed Rep of
Ghana
Greece
Guatemala
Hungary
India
Indonesia
Iran
Iraq
Italy
Ivory Coast
Japan
Kenya
Korea, Dem Peo Rep
Korea, Rep of
Madagascar
Malaysia
Mexico
Morocco
Mozambique
Nepal
Netherlands
Nigeria
Norway
Pakistan
Peru
Philippines
Poland
Portugal
Rhodesia
Romania
Saudi Arabia
South Africa
Spain
Sri Lanka
Sudan
Sweden
Switzerland
Syria
Tanzania
Thailand
Turkey
USSR
Uganda
United Kingdom
Upper Volta
Venezuela
Vietnam
Yugoslavia
Zaire
;;;;
run;quit;

*          _       _   _               _
 ___  ___ | |_   _| |_(_) ___  _ __   / |
/ __|/ _ \| | | | | __| |/ _ \| '_ \  | |
\__ \ (_) | | |_| | |_| | (_) | | | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_| |_|

;

data want;
   set hav1st;
   do i = 1 to n;
      set hav2nd point=i nobs=n;
      text = compbl(tranwrd(text, trim(remove_country),' '));
   end;
   keep text;
run;quit;

*          _       _   _               ____
 ___  ___ | |_   _| |_(_) ___  _ __   |___ \
/ __|/ _ \| | | | | __| |/ _ \| '_ \    __) |
\__ \ (_) | | |_| | |_| | (_) | | | |  / __/
|___/\___/|_|\__,_|\__|_|\___/|_| |_| |_____|

;

data want;

  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
      proc sql;
         select remove_country into :rems separated by "|"
         from hav2nd
      ;quit;
    '));
   end;

   set hav1st;
   rc0=prxparse("s/&rems.//");
   call prxchange(rc0,-1,text,text);
   text=compbl(text);
run;quit;


