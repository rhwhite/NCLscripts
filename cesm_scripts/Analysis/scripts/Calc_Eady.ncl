load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_Eady")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsec")

nyears = endyr-startyr+1

timespans = (/"DJF","ANN"/)
nts = dimsizes(timespans)


cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

Ps = 1013.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/atm/")
	print(Experiment)

    do its = 0,nts-1
        timespan = timespans(its)
        filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam.h0.nc"

        cdf_file = addfile(filename,"r")

        TH = cdf_file->TH
        U = cdf_file->U
        Z = cdf_file->Z3/9.8
        lat = cdf_file->lat

        lat_conform = conform_dims(dimsizes(TH),lat,2)

        printVarSummary(lat_conform)
        result= eady_growth_rate (TH,U,Z,lat_conform,2,0)
        EGR = result[0]
        dUdz = result[1]
        N = result[2]
        printVarSummary(EGR)
        ;-----------------------------------------------------------------------
        ;Write variables to a new netcdf file
        ;-----------------------------------------------------------------------
        filo = "EGR_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam.h0.nc"
        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std,"DefineMode",True)

        ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fAtt@history = "Created by Calc_Eady.ncl"
        fileattdef(fout_std,fAtt)
        
        fout_std->EGR = EGR
        fout_std->dUdz = dUdz
        fout_std->N = N
        fout_std->U = U
        fout_std->Z= Z
        fout_std->TH = TH

        delete([/EGR,N,dUdz/])
        delete([/TH,U,Z,lat,lat_conform/])
        print("printed it")
    end do
end do

end
