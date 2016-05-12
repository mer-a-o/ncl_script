;************************************************
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;************************************************
;  plot_type = ("x11")
  plot_type = ("pdf")

  PBL_opt = (/"YSU","MYJ","MYNN3"/)
;  PBL_opt = (/"MYJ","MYNN3"/)
;  PBL_opt = (/"MYNN3"/)
  num_pbls = dimsizes(PBL_opt)
  num_days = 5
  tower_date = (/20140724,20140725,20140726,20140727,20140728/)

;  tower_date = (/20140801,20140802,20140803,20140804,20140805,20140806,20140807,20140808,20140809,20140810,20140811,20140812,20140813,20140814,20140815,20140816,20140817/)

;  tower_date_short = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17/)
  tower_date_short = (/24,25,26,27,28/)
  data_days = new ((/4,num_days*24/),float)

;do i_day=0,dimsizes(tower_date)-1

do i_day=0,num_days-1
  fdir ="~/OnG/Flight_data/FRAPPE/Ground_measurements/GROUND-BAO-Tower/Fischer_Picarro/PICARRO/"
  fname := "frappe-PICARRO_GROUND-BAO-TOWER_"+tower_date(i_day)+"_R1.maryam.nc"
;  fname := "FRAPPE-troposphericozone_GROUND-BAO-TOWER_"+tower_date(i_day)+"000000_R1_300mtower.maryam.nc"
print (fname)
  file_1 := addfile (fdir+fname,"r") 

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


    lat = 40.05   ;;Erie,CO
    lon = -105.00  
    elev = 1584  ;;m
    elev_010 = elev+6
    elev_100 = elev+300

;;************************************
;; Calc hourly average of obs varibales
;;***********************************

     CH4_hr = new ((/24/),float)
    
    do i_hr=0,23

printVarSummary (CH4_obs)
      CH4_hr (i_hr) = dim_avg_n(CH4_obs(i_hr*3600:(i_hr+1)*3600-1),0)
    end do ;;i_hr

print (CH4_hr)


  wrf_file_sizing = addfile("/nfsscratch/Users/mabdioskouei/Frappe_run/MACCICnBCwOnG_MYNN3/wrfout_d02_2014-07-26_00:00:00.nc","r")
  lat_sizing = wrf_file_sizing->XLAT
  wrf_size=dimsizes(lat_sizing)
  data = new ((/num_pbls+1,24/),float)

  do i_pbl=0,0
    wrfout_path := "/nfsscratch/Users/mabdioskouei/Frappe_run/MACCICnBCwOnG_"+PBL_opt(i_pbl)+"/"

    m_ch4 = new ((/24,52,wrf_size(1),wrf_size(2)/),float)
    m_O3 = new ((/24,52,wrf_size(1),wrf_size(2)/),float)
    m_P = new ((/24,52,wrf_size(1),wrf_size(2)/),float)
    m_T = new ((/24,52,wrf_size(1),wrf_size(2)/),float)
    m_qv = new ((/24,52,wrf_size(1),wrf_size(2)/),float)
    do i_wrft=0,23   ;;;no end do

      if (tower_date_short(i_day).lt.10) then
        if (i_wrft.ge.10) then
          file_name := "wrfout_d02_2014-07-0"+tower_date_short(i_day)+"_"+i_wrft+":00:00"+".nc"
        else 
          file_name := "wrfout_d02_2014-07-0"+tower_date_short(i_day)+"_0"+i_wrft+":00:00"+".nc"
        end if
      else
        if (i_wrft.ge.10) then
          file_name := "wrfout_d02_2014-07-"+tower_date_short(i_day)+"_"+i_wrft+":00:00"+".nc"
        else 
          file_name := "wrfout_d02_2014-07-"+tower_date_short(i_day)+"_0"+i_wrft+":00:00"+".nc"
        end if
      end if

print (file_name)
      wrf_file := addfile(wrfout_path+file_name,"r")

      lat2d := wrf_file->XLAT
      lon2d := wrf_file->XLONG
      dm = dimsizes (lat2d)
;print ("lat2d size ="+dimsizes (lat2d))
      wrf_O3 := wrf_file->o3
      wrf_ch4 := wrf_file->ch4
      wrf_P1 := wrf_file->P
      wrf_PB := wrf_file->PB
      wrf_P := wrf_P1+wrf_PB  ;;Pa
      wrf_qv := wrf_file->QVAPOR

      wrf_theta_p := wrf_file->T
      wrf_theta := wrf_theta_p+300  ;;K 

      wrf_T := wrf_theta * (wrf_P/100000)^(0.286)  ;;temperature in K 
;;----------------Filling the final variables -------------

      m_O3(i_wrft,:,:,:) = wrf_O3
      m_ch4(i_wrft,:,:,:) = wrf_ch4
      m_P(i_wrft,:,:,:) = wrf_P
      m_T(i_wrft,:,:,:) = wrf_T
      m_qv(i_wrft,:,:,:) = wrf_qv
;print (m_T(:,0,123,100))
    end do ;;i_wrft

;;----------Calc for RH--------------
    m_RH = wrf_rh(m_qv,m_P,m_T)
;print (m_RH)

;;--------Variables to calculated height-------------------------------
;;height_wrf is constant in time therefore it can be calculated using just one of the wrfout file.
;;no need to calculate height_wrf for coresponding wrfout
;;----------------------------------------------------------------------

  PHB = wrf_file->PHB      ;base-state geopotential height (m2/s2)
  PH = wrf_file->PH        ;geopotential height (m2/s2)
  HGT = wrf_file->HGT      ;terrian height (m)
  height_wrf_loweredge = (PHB+PH)/9.81   ;Height from the sea level

  data_size = dimsizes(height_wrf_loweredge)
  height_wrf_midgrid  = new (data_size,float) 

  do i_btt=0,51
     height_wrf_midgrid (:,i_btt,:,:) = (height_wrf_loweredge (:,i_btt,:,:)+height_wrf_loweredge (:,i_btt+1,:,:))/2
  end do ;i_btt
;;print (height_wrf_midgrid)
;;----End calculating height_wrf
;;-------------------------------  
;;Find corespinding i and j index in the model
;;------------------------------
  int_opt = True
  wrf_ind_flight := wrf_user_ll_to_ij(wrf_file, lon,lat,int_opt)
  wrf_ind_flight := wrf_ind_flight -1
print ("INDEXES"+wrf_ind_flight)



   data (i_pbl,:) = m_ch4(:,1,wrf_ind_flight(1),wrf_ind_flight(0))   ;;300m is 5th layer

  delete (m_ch4)


end do ;i_pbl

  data (num_pbls,:) = (/CH4_hr/)
  data_days (:,24*i_day:24*i_day+23) = data
delete (CH4_hr)

end do ;;i_day

print (data_days)

;;*****************************************************************
  plot_name = "obs_vs_model_CH4_300m"
  wks  = gsn_open_wks (plot_type,plot_name)		;open workstation
 
  res  = True
  res@tiMainString     = "Obs_300m"         ; add title
  res@tiMainFontHeightF = 0.015


  
  res@tiYAxisString    = "CH4-ppm"    ; y-axis label
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
  res@xyExplicitLegendLabels = (/"YSU","MYJ","MYNN3","OBS"/)

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

printVarSummary (data_days)
printVarSummary (time_hr_p)

  plot1 = gsn_csm_xy (wks,time_hr_p,data_days ,res)
;print (time_hr)


  delete (res)
;  delete (restick)
  delete (data)
;  delete(time_ref)
  delete (time)




