#!/bin/bash

# Example:

#./vercross_ncl_d01_90hrs.sh 2016-05-09_06:00:00 co 1 /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/output/20160509/ . 1



#mkdir /localscratch/Users/psaide
#cd /localscratch/Users/psaide/
#export NCARG_ROOT=/Users/psaide/ncl/precompiled_noOpenDAP_6.3.0

start_date=$1
var_name=$2
wrf_domain=$3
wrf_folder=$4
plot_folder=$5
station_num=$6


plotname=${var_name}-vercross

cat > ${plotname}\_${start_date}\_${station_num}.tmp <<EOF

;;==================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;;=================================================
begin
 start_date = "$start_date"
 var_name = "$var_name"
 wrf_folder = "$wrf_folder"
 plot_folder = "$plot_folder"
 wrf_domain = "$wrf_domain"
 ij_station = $station_num


 start_month     = toint(str_get_field(start_date, 2, "-_.:"))
 start_day        = toint(str_get_field(start_date, 3, "-_.:")) 
 start_hour      = toint(str_get_field(start_date, 4, "-_.:")) 
 ;;============================
;;Station information-New station can be added to end of the arrays
;;===========================
   station_lat_arr = (/37.3123,37.5220,33.2920,37.4580,37.5640,37.3389,37.9660\
   ,36.5389,35.2280,35.2350,37.7710,35.9619,35.8500,34.9128,35.5819, 37.0800\
   ,37.5689,37.68712,33.941945,32.122778,33.94194444,35.941072,36.35,43.4567\
   ,33.240962,32.751626,26.866919,37.451041,33.524161,33.5482424,43.7004,39.97689/)

   station_lon_arr = (/127.3105,127.1200,126.1620,126.9510,126.9350,127.2658\
   ,124.6300,126.3295,126.8430,129.0830,128.8670,127.0050,128.5800,126.4369\
   ,129.1897,127.0400,126.6397,128.75872,124.592778,125.181945,124.5927778\
   ,126.683008,127.38,143.7661,130.288239,128.681728,128.248465,137.358972\
   ,130.475492,130.3650523,132.1635,116.38137/)


   station_name = (/"Taehwa Research Forest","Olympic Park", "Gosan (Jeju Island)"\
   ,"Seoul_SNU","Yonsei_University","Hankuk_UFS","Baengnyeong Island","Anmyeon"\
   ,"GIST (Gwangju)","Pusan Univ. (Busan)","Gangneung-Wonju Univ.","Iksan","Kyungpook NU"\
   ,"Mokpo University","Ulsan UNIST","Osan","NIER","Daegwallyeong","Gageocho","Ieodo"\
   ,"Jeonju","Kunsan University", "Daejeon", "Rikubetsu (Japan)","Saga (Japan)","Fukue (Japan)"\
   ,"Cape Hedo (Japan)","Noto (Japan)","Kasuga (Japan)", "Fukuoka (Japan)","Ussuriysk","Beijing"/)


;;=========================================
;;Open WRF- Read vars-
;;======================================

;  num_hrs = 30  ;; How many wrfout you want to plot
;  num_hrs_2 = 82  ;; How many wrfout you want to plot
  num_hrs_2 = 91  ;; How many wrfout you want to plot

  var_mat = new ((/100,num_hrs_2/),float)  ;;100 horizontal layer, 39 hours
;  day_from_start := 0
  FILES = systemfunc( " ls "+wrf_folder+"/wrfout_d0"+wrf_domain+"_*")
  num_files = dimsizes (FILES)

  do hr_wrf=0,num_files-1 ;;plot num_hrs  hourly  forcasts in one plot
     wrf_file := addfile(FILES(hr_wrf),"r")
print(FILES(hr_wrf))

;  do hr_wrf=start_hour,(num_hrs_2+start_hour-1),3 ;;plot num_hrs  hourly  forcasts in one plot 
;    if (hr_wrf.ge.24)
;      hr_wrf_d := hr_wrf-(hr_wrf/24)*24
;    else 
;      hr_wrf_d := hr_wrf
;    end if
;    start_day_d := start_day+(hr_wrf/24)
;
;    if (start_day_d.gt.30)
;      start_month_d:=start_month+(start_day_d/30)
;      start_day_d:=start_day_d-(start_day_d/30)*30
;    else
;      start_month_d := start_month
;    end if
;
;   
;print (hr_wrf_d)
;;;=========Building wrf_date_name============
;    if (start_day_d.ge.1 .and. start_day_d.lt.9) then
;
;      if (hr_wrf_d.le.9) then
;         wrf_date_name := "2016-0"+start_month_d+"-0"+start_day_d+"_0"+hr_wrf_d+":00:00.nc"
;      else if (hr_wrf_d.ge.10 .and. hr_wrf_d.le.23) then
;         wrf_date_name := "2016-0"+start_month_d+"-0"+start_day_d+"_"+hr_wrf_d+":00:00.nc"
;      end if 
;      end if
;    else if (start_day_d.eq.9) then
;
;      if (hr_wrf_d.le.9) then
;         wrf_date_name := "2016-0"+start_month_d+"-0"+start_day_d+"_0"+hr_wrf_d+":00:00.nc"
;      else if (hr_wrf_d.ge.10 .and. hr_wrf_d.le.23) then
;         wrf_date_name := "2016-0"+start_month_d+"-0"+start_day_d+"_"+hr_wrf_d+":00:00.nc"
;      end if
;      end if
;
;    else if (start_day_d.ge.10) then
;
;      if (hr_wrf_d.le.9) then
;         wrf_date_name := "2016-0"+start_month_d+"-"+start_day_d+"_0"+hr_wrf_d+":00:00.nc"
;      else if (hr_wrf_d.ge.10 .and. hr_wrf_d.le.23) then
;         wrf_date_name := "2016-0"+start_month_d+"-"+start_day_d+"_"+hr_wrf_d+":00:00.nc"
;
;      end if
;      end if
;
;    end if  ;;start_day
;    end if 
;    end if 
;;=====================================       
;print (wrf_date_name)
; 
;  wrf_file := addfile(wrf_folder+"/wrfout_d0"+wrf_domain+"_"+wrf_date_name,"r")
;
;;================================================
;; Setting Levels and unit conversion for var_name
;;===============================================

  if (var_name.eq."co")
     Levels = (/ 15., 30., 40., 50., 60., 70., 80.,100., 120., 140., 160., 200. /)
     wrf_var_ppm := wrf_user_getvar(wrf_file,"co",0)
     wrf_var := wrf_var_ppm*1000
     wrf_var@units = "ppb"
     wrf_var@description = "CO conc."
     
  end if
  if (var_name.eq."o3")
     Levels = (/ 20., 30., 40., 50., 60., 70., 80., 100., 150., 200., 300. /) 
     wrf_var_ppm := wrf_user_getvar(wrf_file,"o3",0)
     wrf_var := wrf_var_ppm*1000
     wrf_var@units = "ppb"
     wrf_var@description = "O3 conc."

  end if
  if (var_name.eq."no3")
     Levels = 0.1*(/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500. /)
     aer_a01 = wrf_user_getvar(wrf_file,"no3_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"no3_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"no3_a03",0)
     wrf_var = (aer_a01+aer_a02+aer_a03) ; less than 2.5 um
     wrf_var@units = "ug/kg"
     wrf_var@description = str_upper("no3") + " < 2.5um Concentration"
  end if
  if (var_name.eq."bc")
     Levels = 0.1*(/ 0.05, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200. /)
     aer_a01 = wrf_user_getvar(wrf_file,"bc_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"bc_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"bc_a03",0)
     wrf_var = (aer_a01+aer_a02+aer_a03) ; less than 2.5 um
     wrf_var@units = "ug/kg"
     wrf_var@description = str_upper("bc") + " < 2.5um Concentration" 
  end if
  if (var_name.eq."oa")
     Levels := 0.1*(/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500. /)
     aer_a01 = wrf_user_getvar(wrf_file,"oc_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"oc_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"oc_a03",0)
     smpa_a01 = wrf_user_getvar(wrf_file,"smpa_a01",0)
     smpa_a02 = wrf_user_getvar(wrf_file,"smpa_a02",0)
     smpa_a03 = wrf_user_getvar(wrf_file,"smpa_a03",0)
     smpbb_a01 = wrf_user_getvar(wrf_file,"smpbb_a01",0)
     smpbb_a02 = wrf_user_getvar(wrf_file,"smpbb_a02",0)
     smpbb_a03 = wrf_user_getvar(wrf_file,"smpbb_a03",0)
     biog1_c_a01 = wrf_user_getvar(wrf_file,"biog1_c_a01",0)
     biog1_c_a02 = wrf_user_getvar(wrf_file,"biog1_c_a02",0)
     biog1_c_a03 = wrf_user_getvar(wrf_file,"biog1_c_a03",0)

     wrf_var = (aer_a01+aer_a02+aer_a03+ \\
                smpa_a01+smpa_a02+smpa_a03+ \\
                smpbb_a01+smpbb_a02+smpbb_a03+ \\
                biog1_c_a01+biog1_c_a02+biog1_c_a03) ; less than 2.5 um
     wrf_var@units = "ug/kg"
     wrf_var@description = str_upper("oa") + " < 2.5um Concentration" 
  end if

  if (var_name.eq."so4")
     Levels := 0.1*(/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500. /) 
     aer_a01 = wrf_user_getvar(wrf_file,"so4_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"so4_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"so4_a03",0)
     wrf_var = (aer_a01+aer_a02+aer_a03) ; less than 2.5 um
     wrf_var@units = "ug/kg"
     wrf_var@description = str_upper("so4") + " < 2.5um Concentration" 
  end if
  if (var_name.eq."pm25")
     Levels := (/ 0.1, 1., 2., 5., 10., 20., 40., 60., 100., 150., 200. /)
     aer_a01 = wrf_user_getvar(wrf_file,"PM2_5_DRY",0)
     rho_inv = wrf_user_getvar(wrf_file,"ALT",0) ; inverse density
     wrf_var = aer_a01*rho_inv ; convert to ug/kg
     wrf_var@units = "ug/kg"
     wrf_var@description = " Dry PM2.5 Concentration"
  end if
  if (var_name.eq."nox")
     Levels := 0.1*(/ 0.02, 0.05, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100. /)
     no = wrf_user_getvar(wrf_file,"no",0)
     no2 = wrf_user_getvar(wrf_file,"no2",0)
     wrf_var = 1000.0*(no+no2)
     wrf_var@units = "ppb"
     wrf_var@description = "NOx conc."
  end if
  if (var_name.eq."aod")
    Levels = (/ 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8  /)  
    aod400 = wrf_user_getvar(wrf_file,"EXTAER2",0)
    aod600 = wrf_user_getvar(wrf_file,"EXTAER3",0)
    wrf_var = 0.25*aod400 + 0.75*aod600
    wrf_var@units = "1/km"
    wrf_var@description = "550nm Aerosol Extinction"
  end if
  if (var_name.eq."so2")
     Levels := 0.01*(/ 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500., 1000., 2000. /)
     wrf_var_ppm = wrf_user_getvar(wrf_file,"so2",0)
     wrf_var = wrf_var_ppm*1000.
     wrf_var@units = "ppb"
     wrf_var@description = "SO2 conc."
  end if
  if (var_name.eq."iso")
;     Levels = 0.01*(/ 0.5, 1., 2., 3., 4., 6., 8., 10. /)
     Levels = 0.1*(/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 70., 100., 200. /)

     wrf_var_ppm = wrf_user_getvar(wrf_file,"isopr",0)
     wrf_var = wrf_var_ppm*1000.
     wrf_var@units = "ppb"
     wrf_var@description = "Isoprene conc."
  end if
  if (var_name.eq."oin-coarse")
     Levels := (/ 0.01, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200. /)
     aer_a01 = wrf_user_getvar(wrf_file,"oin_a03",0)
     aer_a02 = wrf_user_getvar(wrf_file,"oin_a04",0)
     wrf_var = (aer_a01+aer_a02) ; less than 625 nm
     wrf_var@units = "ug/kg"
     wrf_var@description = "Coarse other Inorganics (Dust included, > 625nm) Concentration"
  end if
  if (var_name.eq."oin-fine")
     Levels := (/ 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50. /)
     aer_a01 = wrf_user_getvar(wrf_file,"oin_a03",0)
     aer_a02 = wrf_user_getvar(wrf_file,"oin_a04",0)
     wrf_var = (aer_a01+aer_a02) ; less than 625 nm
     wrf_var@units = "ug/kg"
     wrf_var@description = "Fine other Inorganics (Dust included, < 625nm) Concentration"
  end if
  if (var_name.eq."seasalt-coarse")
     Levels := (/ 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50. /)
     aer_a01 = wrf_user_getvar(wrf_file,"na_a03",0)
     aer_a02 = wrf_user_getvar(wrf_file,"na_a04",0)
     aer_a03 = wrf_user_getvar(wrf_file,"cl_a03",0)
     aer_a04 = wrf_user_getvar(wrf_file,"cl_a04",0)
     wrf_var = (aer_a01+aer_a02+aer_a03+aer_a04) ; less than 625 nm
     wrf_var@units = "ug/kg"
     wrf_var@description = "Coarse Sea Salt (> 625nm) Concentration"
  end if
  if (var_name.eq."seasalt-fine")
     Levels := (/ 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50. /)
     aer_a01 = wrf_user_getvar(wrf_file,"na_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"na_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"cl_a01",0)
     aer_a04 = wrf_user_getvar(wrf_file,"cl_a02",0)
     wrf_var = (aer_a01+aer_a02+aer_a03+aer_a04) ; less than 625 nm
     wrf_var@units = "ug/kg"
     wrf_var@description = "Fine Sea Salt (< 625nm) Concentration"
  end if
  if (var_name.eq."hcho")
     Levels :=  0.1*(/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 70., 100., 200. /)
     wrf_var_ppm = wrf_user_getvar(wrf_file,"hcho",0)
     wrf_var = wrf_var_ppm*1000.
     wrf_var@units = "ppb"
     wrf_var@description = "Formaldehyde conc."
  end if
  if (var_name.eq."num")
     Levels := (/ 1.e7, 2.e7, 5.e7, 1.e8, 2.e8, 5.e8, 1.e9, 2.e9, 5.e9,1.e10, 2.e10 /)
     aer_a01 = wrf_user_getvar(wrf_file,"num_a01",0)
     aer_a02 = wrf_user_getvar(wrf_file,"num_a02",0)
     aer_a03 = wrf_user_getvar(wrf_file,"num_a03",0)
     wrf_var = (aer_a01+aer_a02+aer_a03) ; less than 2.5 um
     wrf_var@units = "#/kg"
     wrf_var@description = "Aerosol Number < 2.5um Concentration"
  end if
  if (var_name.eq."tracer-anthro")
     Levels := (/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500. /)
     co1 = wrf_user_getvar(wrf_file,"voca",0)
     co2 = wrf_user_getvar(wrf_file,"smpa",0)
     wrf_var = (co1+co2)*1000.*250./(0.04*28.) ;units are in voc precursor, change to CO
     wrf_var@units = "ppb"
     wrf_var@description = "CO anthropogenic"
  end if
  if (var_name.eq."tracer-bb")
     Levels := (/ 0.1, 0.2, 0.5, 1., 2., 5.,10., 20., 50., 100., 200., 500. /)
     co1 = wrf_user_getvar(wrf_file,"vocbb",0)
     co2 = wrf_user_getvar(wrf_file,"smpbb",0)
     wrf_var = (co1+co2)*1000.*250./(0.04*28.) ;units are in voc precursor, change to CO
     wrf_var@units = "ppb"
     wrf_var@description = "CO biomass burning"
  end if
;;=============================
   wrf_var@long_name = var_name
printVarSummary (wrf_var)
   z   := wrf_user_getvar(wrf_file, "z",0)      ; grid point height
   ww_lat := wrf_user_getvar(wrf_file, "XLAT",0)
   ww_lon := wrf_user_getvar(wrf_file, "XLONG",0)
;;============================
;; Loop over stations
;;===========================
    
   int_opt = True
    wrf_ind_station := wrf_user_ll_to_ij(wrf_file, station_lon_arr(ij_station),station_lat_arr(ij_station),int_opt)
    wrf_ind_station := wrf_ind_station-1

;print ("MID grid (lat,lon)="+ ww_lat(wrf_ind_station(1),wrf_ind_station(0))+","+ ww_lon(wrf_ind_station(1),wrf_ind_station(0)))
;print (wrf_ind_station)
    plane := (/wrf_ind_station(0), wrf_ind_station(1)/)    ; pivot point is center of domain (x,y)
    opts_cr = False
    angle = 0  ;; if 90 then read var_plane(:,wrf_ind_station(1))
    var_plane = wrf_user_intrp3d(wrf_var,z,"v",plane,angle,opts_cr)
;printVarSummary(var_plane)

    var_mat(:,(hr_wrf*3)) = var_plane(:,wrf_ind_station(1))
    delete(var_plane)

  end do ;;hr_wrf
;print (var_mat)
;;======================
;;Interpolation 
;;======================

  do i_L=1,num_hrs_2-3,3
      var_mat(:,i_L) = (2*var_mat(:,i_L-1)+var_mat(:,i_L+2))/3
  end do ;;i_L
  do i_R=2,num_hrs_2-2,3
      var_mat(:,i_R) = (var_mat(:,i_R-2)+2*var_mat(:,i_R+1))/3
  end do ;;i_l


  ;;===========WKS and general plotting Resources==============
;  plot_type = "pdf"
  plot_type = "x11"
  plot_name = "$plot_folder/plt_${plotname}_stn_"+(ij_station)

  plot_type@wkPaperWidthF  =  6.375  ; in inches 
  plot_type@wkPaperHeightF =  10.5  ; in inches
  wks = gsn_open_wks(plot_type,plot_name)
  gsn_define_colormap(wks,"wh-bl-gr-ye-re")     ; choose color map
  
  res                     = True          ; plot mods desired

  res@tiMainString    = station_name(ij_station)+", "+station_lat_arr(ij_station)+"N."+station_lon_arr(ij_station)+"E."  
  res@gsnMaximize   = True            ; Maximize plot in frame
  res@tmXTOn                  = False
  res@tmYROn                  = False


  res@tiYAxisString         = "Height (km)"
  res@tiMainFontHeightF   = 0.02
  res@tiXAxisFontHeightF   = 0.02
  res@tiYAxisFontHeightF   = 0.02
  res@tmXBLabelFontHeightF    = 0.01
  

  res@cnFillOn = True                          ; Create a color fill plot
  res@cnLinesOn = False

  res@gsnSpreadColorEnd = -3  ; End third from the last color in color map
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels             = Levels
  
  res@vpWidthF            = 0.7           ; change aspect ratio of plot
  res@vpHeightF           = 0.5

  res@gsnMaximize         = True          ; maximize plot size



  ttime = fspan (0,num_hrs_2-1,num_hrs_2)
  ttime@units = "hours since 2016-"+(str_get_field(start_date, 2, "-_.:"))+"-"+(str_get_field(start_date, 3, "-_.:"))+" "+str_get_field(start_date, 4, "-_.:")+":00:0.0"

  var_mat!0 = "Height"
  var_mat!1 = "time"
  var_mat&time = ttime  
  restick = True
  restick@ttmFormat = "%N-%D_%HZ"
;  restick@ttmNumTicks = 2  ;;How many tickmark on X axis?
 

  restick@ttmValues = (/(/2016,start_month,start_day,0,0,0/), \
                      (/2016,start_month+(start_day+1)/32,(start_day+1)-31*((start_day+1)/32),0,0,0/), \
                      (/2016,start_month+(start_day+2)/32,(start_day+2)-31*((start_day+2)/32),0,0,0/), \
                      (/2016,start_month+(start_day+3)/32,(start_day+3)-31*((start_day+3)/32),0,0,0/) /)


  time_axis_labels(var_mat&time,res,restick) ; call the formatting procedure

  res@tmXBLabelFontHeightF    = 0.013

  plot = gsn_csm_contour(wks,var_mat(2:12,0:num_hrs_2-1),res)


end
;;================================================
EOF


mv ${plotname}\_${start_date}_${station_num}.tmp ${plotname}\_${start_date}\_${station_num}.ncl

#PATH=/Users/psaide/ncl/precompiled_noOpenDAP_6.3.0/bin:$PATH
#export NCARG_ROOT=/Users/psaide/ncl/precompiled_noOpenDAP_6.3.0
ncl ${plotname}\_${start_date}\_${station_num}.ncl


#command= "pdfcrop plt_${plotname}_stn_$i"
command="pdfcrop ${plot_folder}/plt_${plotname}_stn_${station_num}.pdf plt_${plotname}_stn_${station_num}_crop.pdf"
echo $command
eval $command
mv plt_${plotname}_stn_${station_num}_crop.pdf  ${plot_folder}/plt_${plotname}_stn_${station_num}.pdf
gs -SDEVICE=png16m -r125 -dAutoRotatePages=/none -sOutputFile=${plot_folder}/plt_${plotname}_stn_${station_num}.png -dNOPAUSE -dBATCH ${plot_folder}/plt_${plotname}_stn_${station_num}.pdf
/usr/bin/convert ${plot_folder}/plt_${plotname}_stn_${station_num}.png -rotate -90 ${plot_folder}/plt_${plotname}_stn_${station_num}.png

#rm ${plot_folder}/plt_${plotname}_stn_${station_num}.pdf
#rm ${plotname}\_${start_date}\_${station_num}.ncl

#for g in ${plot_folder}/*crop.pdf*
#do
#  echo "cleaning -$g"
#  rm $g
#
#done



