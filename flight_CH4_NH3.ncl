

  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;;*************************************************************************

  plot_type ="pdf"  
; plot_type = "X11"

  date_arr =(/"20140726","20140727","20140728","20140729","20140731","20140802","20140803","20140806","20140807","20140808","20140811","20140812","20140815","20140816","20140818"/)

  var1_name = "CH4"
  var2_name = "NH3"
;;===========================================================================
;; Read Flight Data
;;=====================================================================
  flight_path = "/Users/mabdioskouei/OnG/Flight_data/FRAPPE/ict_handling/"
  do file_idx=0,dimsizes (date_arr)-1
    flight_date := date_arr(file_idx)
    flight_name := "frappe-mrg60-c130_merge_"+flight_date+"_R0.maryam.nc"
    flight_file = addfile(flight_path+flight_name,"r")
    flight_time := flight_file->time

    var1 := (flight_file->CH4_MixingRatio)/1000 ;;ppbv
    var2 := (flight_file->NH3_MixingRatio) ;; ppb
;;==================================================================
;;Plotting
;;==================================================================
    plot_name = var1_name+"_"+var2_name+"_Obs_date_"+flight_date 
    wks  = gsn_open_wks (plot_type,plot_name)		;open workstation

    resL = True
    resL@tiMainString = plot_name 
    resL@tiMainFontHeightF = 0.015

    resL@tiYAxisString    = "CH4-ppmv"    ; y-axis label
    resL@tiXAxisString    = "UTC"    ; x-axis label
    resL@tiXAxisFontHeightF  = 0.017            ; change title font heights

    resL@vpHeightF              = 0.45
    resL@vpWidthF               = 0.73
    resL@vpXF                   = 0.15 ; set left hand side start point of plot
                                    ; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
    resL@xyMarkLineModes = (/"Lines"/)    ; Markers *and* lines
    resL@xyLineThicknesses = (/4/)               ; make 2nd lines thicker
    resL@xyLineColors      = (/"deepskyblue3"/)          ; change line color
    resL@xyDashPatterns    =(/0/)

    resL@pmLegendDisplayMode    = "Always"              ; turn on legend
    resL@pmLegendSide           = "Bottom"                 ; Change location of
    resL@pmLegendWidthF         = 0.12                  ; Change width and
    resL@pmLegendHeightF        = 0.18                  ; height of legend.
    resL@lgLabelFontHeightF     = .015                   ; change font height
    resL@lgPerimOn              = False                 ; no box around


    resR  = True 
    resR@tiYAxisString    = "NH3-ppbv"    ; y-axis label
    resR@tiXAxisFontHeightF  = 0.01            ; change title font heights

    resR@xyMarkLineModes = (/"Lines"/)    ; Markers *and* lines
    resR@xyLineThicknesses = (/3/)               ; make 2nd lines thicker
    resR@xyLineColors      = (/"Red"/)          ; change line color
    resR@xyDashPatterns    =(/0/)

;    resR@xyMarkLineModes = (/"Markers"/)    ; Markers *and* lines
;    resR@xyMarker = 1
;    resR@xyMarkerColor     = "Red"
;    resR@xyMarkerSizeF      = 0.02


    resR@pmLegendDisplayMode    = "Always"              ; turn on legend
    resR@pmLegendSide           = "Bottom"                 ; Change location of
    resR@pmLegendWidthF         = 0.12                  ; Change width and
    resR@pmLegendHeightF        = 0.2                  ; height of legend.
    resR@lgLabelFontHeightF     = .015                   ; change font height
    resR@lgPerimOn              = False                 ; no box around



    resL@xyExplicitLegendLabels  = var1_name
    resR@xyExplicitLegendLabels  = var2_name


    resL@trYMinF = 1.8
    resL@trYMaxF = 2.1

    resR@trYMinF = 0
    resR@trYMaxF = 30



   restick = True
   restick@ttmFormat = "%H:00Z"
   time_axis_labels(flight_time,resL,restick)


    plot = gsn_csm_xy2(wks,flight_time,var1,var2,resL,resR)
  
    delete (restick)
    delete(resL)
    delete(resR)
  end do ;;file_idx



















