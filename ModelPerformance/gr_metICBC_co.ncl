;************************************************
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;;************************************************
;  plot_type = ("x11")
  plot_type = ("pdf")

    tower_date = (/20140724,20140725,20140726,20140727,20140728,20140729,20140730,20140731,20140801,20140802,20140803,20140804,20140805,20140806,20140807,20140808,20140809,20140810,20140811,20140812,20140813,20140814,20140815,20140816,20140817/)

  tower_date_short = (/24,25,26,27,28,29,30,31,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17/)
  num_days = dimsizes (tower_date)

;  num_days = 8
  data_days = new ((/3,num_days*24/),float)  ;;  [FNL,ECMWF,OBS]

  wrf_path_FNL := "/nfsscratch/Users/mabdioskouei/Frappe_run/MACCICnBCwOnG_MYNN3/"
  wrf_path_ECMWF := "/nfsscratch/Users/mabdioskouei/Frappe_run/ERA_MACCICnBCwOnG_MYNN3/"

  FILES_FNL = systemfunc( " ls "+wrf_path_FNL+"/wrfout_d02_2014-0*")
  FILES_ECMWF = systemfunc( " ls "+wrf_path_ECMWF+"/wrfout_d02_2014-0*")
  num_files = dimsizes (FILES_FNL)

  obs_path ="~/OnG/Flight_data/FRAPPE/Ground_measurements/GROUND-BAO-Tower/Fischer_Picarro/PICARRO/"

do i_day=0,num_days-1
  obs_name := "frappe-PICARRO_GROUND-BAO-TOWER_"+tower_date(i_day)+"_R1.maryam.nc"
;  fname := "FRAPPE-troposphericozone_GROUND-BAO-TOWER_"+tower_date(i_day)+"000000_R1_300mtower.maryam.nc"
  file_1 := addfile (obs_path+obs_name,"r") 

;;*******************************
;; Read different variables from the Obs file
;********************************

   time := file_1->time
   time@units:=  "seconds since_"+tower_date(i_day)+"_00:00:0.0"
   time!0    := "time"
   time&time :=  time 
;print (time)

;    O3_ppb := file_1->O3_MR   ;;ppbv
;    O3 := O3_ppb/1000

    CH4_obs := file_1->CH4_ppmv
    CO_obs := (file_1->CO_ppbv)/1000


    lat = 40.05   ;;Erie,CO
    lon = -105.00  
    elev = 1584  ;;m
    elev_010 = elev+6
    elev_100 = elev+300

;;************************************
;; Calc hourly average of obs varibales
;;***********************************

   obs_hr = new ((/24/),float)
    
   do i_hr=0,23
     obs_hr (i_hr) = dim_avg_n(CO_obs(i_hr*3600:(i_hr+1)*3600-1),0)
   end do ;;i_hr
   data_days (2,24*i_day:24*i_day+23) = obs_hr
end do ;;i_day

  wrf_file_sizing = addfile("/nfsscratch/Users/mabdioskouei/Frappe_run/MACCICnBCwOnG_MYNN3/wrfout_d02_2014-07-26_00:00:00.nc","r")
  lat_sizing = wrf_file_sizing->XLAT
  wrf_size=dimsizes(lat_sizing)

  m_var = new ((/num_files,1,1,1/),float)

do i_met=0,1
  do hr_wrf=0,num_files-1 ;;plot num_hrs  hourly  forcasts in one plot
    if (i_met.eq.0)
      wrf_file := addfile(FILES_FNL(hr_wrf),"r")
      print(FILES_FNL(hr_wrf))
    else 
      wrf_file := addfile(FILES_ECMWF(hr_wrf),"r")
      print(FILES_ECMWF(hr_wrf))
    end if

    lat2d := wrf_file->XLAT
    lon2d := wrf_file->XLONG
    dm = dimsizes (lat2d)
;print ("lat2d size ="+dimsizes (lat2d))
    wrf_O3 := wrf_file->o3
    wrf_ch4 := wrf_file->ch4
    wrf_co := wrf_file->co
    wrf_P1 := wrf_file->P
    wrf_PB := wrf_file->PB
    wrf_P := wrf_P1+wrf_PB  ;;Pa
    wrf_qv := wrf_file->QVAPOR

    wrf_theta_p := wrf_file->T
    wrf_theta := wrf_theta_p+300  ;;K 

    wrf_T := wrf_theta * (wrf_P/100000)^(0.286)  ;;temperature in K 

    int_opt = True
    wrf_ind_flight := wrf_user_ll_to_ij(wrf_file, lon,lat,int_opt)
    wrf_ind_flight := wrf_ind_flight -1
print ("INDEXES"+wrf_ind_flight)

;;----------------Filling the final variables -------------

    m_var(hr_wrf,:,:,:) = wrf_co (0,5,wrf_ind_flight(0),wrf_ind_flight(1))
  end do ;;hr_wrf
;;------------------------------
printVarSummary (m_var)
printVarSummary(data_days)

  data_days (i_met,:) = m_var(:,0,0,0)   ;;300m is 5th layer
;  delete (m_ch4)

end do ;;i_met

print (data_days)

;;*****************************************************************
  plot_name = "obs_vs_METmodel_CO"
  wks  = gsn_open_wks (plot_type,plot_name)		;open workstation
 
  res  = True
  res@tiMainString     = "Obs_July"         ; add title
  res@tiMainFontHeightF = 0.015


  
  res@tiYAxisString    = "CO-ppm"    ; y-axis label
  res@tiXAxisString    = "UTC"    ; x-axis label
  res@tiXAxisFontHeightF  = 0.015            ; change title font heights
  res@tiYAxisFontHeightF  = 0.015            ; change title font heights



  res@pmLegendDisplayMode    = "Always"              ; turn on legend
  res@pmLegendSide           = "Bottom"                 ; Change location of
    ;  res@pmLegendParallelPosF   = .90                   ; move units right
    ;  res@pmLegendOrthogonalPosF = -0.8                  ; more neg = down

  res@pmLegendWidthF         = 0.12                  ; Change width and
  res@pmLegendHeightF        = 0.1                  ; height of legend.
  res@lgLabelFontHeightF     = .015                   ; change font height
  res@lgPerimOn              = False                 ; no box around
  res@xyExplicitLegendLabels = (/"FNL","ECMWF","OBS"/)

  res@tmXBLabelFontHeightF = 0.015                ;Font height of the Thickmarks label

  res@vpHeightF              = 0.4
  res@vpWidthF               = 0.8
  res@vpXF                   = 0.15 ; set left hand side start point of plot
                                    ; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
;  res@vpYF                   = 0.6     ; set top start point of plot


;  restick = True
;  restick@ttmFormat = "%H"
;  time_axis_labels(time,res,restick)


;;*******************************************

  res@xyMarkLineModes = (/"Lines","Lines","Markers"/)    ; Markers *and* lines
  res@xyLineThicknesses = (/4,4,2/)               ; make 2nd lines thicker
  res@xyLineColors      = (/"blue3","green2","black"/)          ; change line color
  res@xyDashPatterns    =(/0,0,0,7/)

  res@xyMarker = 16
  res@xyMarkerColor     = "black"
  res@xyMarkerSizeF      = 0.005

;  res@trXminF = 17

  time_hr_p = ispan (1,(num_days)*24,1) 
  time_hr_p@units = "hours since 2014-07-23 00:00:0.0"

  data_days!1 = "time"
  data_days&time = time_hr_p  
  restick = True
  restick@ttmFormat = "%N-%D"
  restick@ttmNumTicks = 8  ;;How many tickmark on X axis?
  time_axis_labels(data_days&time,res,restick) ; call the formatting procedure

printVarSummary (data_days)
printVarSummary (time_hr_p)

  plot1 = gsn_csm_xy (wks,time_hr_p,data_days ,res)
;print (time_hr)


  delete (res)
;  delete (restick)
;  delete (data)
;  delete(time_ref)
;  delete (time)




