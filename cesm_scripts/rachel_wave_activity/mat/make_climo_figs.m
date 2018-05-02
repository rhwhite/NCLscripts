% Paths
set_paths
% loads TN2001path and basepath
% ltm files are in basepath/var/var.ltm.nc, where var == air, hgt, uwnd, or vwnd. 366-day climos.
% Monthly climatologies of the WAF stuff are in basepath/derived/misc/TN2001.var.ClmMon.nc, where var == Fx, Fy, Fz, psidev, NN.

% Load and make u, v, hgt climatologies at select levels
%   (level = 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10)
level = ncread([basepath '/uwnd/uwnd.ltm.nc'],'level');
lat = ncread([basepath '/uwnd/uwnd.ltm.nc'],'lat');
lon = ncread([basepath '/uwnd/uwnd.ltm.nc'],'lon');

nc = 21;
cmap = (flipud(lbmap(nc,'redblue')));
cmap(ceil(nc/2),:) = [1 1 1];

% Get months from day index for a leap year (366 day climo)
dayNums = 1:366;
dates = datenum(2012,1,1) + dayNums - 1;
[~,mm,~,~,~,~] = datevec(dates);

if 0 % Standard u, v, hgt fields
varNames = {'uwnd','vwnd','hgt'};
for jvar = 1:length(varNames)
   theVar = ncread([basepath '/' varNames{jvar} '/' varNames{jvar} '.ltm.nc'],[varNames{jvar} 'ClmSm']);
  for jlev = [3 6 10];
%   figure(1)
%   clf
  for jmo = 1:12
%   subplot(3,4,jmo)
   figure('Visible','Off')
%   figure(1)
   clf
   fld = double(squeeze(mean(theVar(:,:,jlev,find(mm==jmo)),4)));
   if jvar < 3
      clevs = prctile(abs(fld(:)),95)*linspace(-1,1,nc);
      cmap = (flipud(lbmap(nc,'redblue')));
      cmap(ceil(nc/2),:) = [1 1 1];
   else
      clevs = linspace(min(fld(:)),max(fld(:)),nc);
      cmap = (flipud(lbmap(nc,'redblue')));
   end
   colormap(cmap)
   m_proj('miller','lon',[0 360]);
   [ha,hb] = m_contourf(lon,lat,fld',clevs);
%   shading flat
   set(hb,'edgecolor','none')
   caxis([min(clevs) max(clevs)])
   hold on
   m_grid('box','fancy')
   m_coast('color',[0 0 0]);
%   if jvar < 3
%      caxis(prctile(abs(fld(:)),95)*[-1 1])
%   end
   colorbar
   title([varNames{jvar} ', ' num2str(level(jlev)) ' mb (month = ' num2str(jmo) ')'])
%   export_fig(['../figures/' varNames{jvar} '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.pdf'])
   drawnow
   print('-dpsc',['../figures/' varNames{jvar} '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.eps'])
   close all
  end
  end

end
end


if 1 % Special case: u with fixed color scales by level
varNames = {'uwnd'};
for jvar = 1:length(varNames)
   theVar = ncread([basepath '/' varNames{jvar} '/' varNames{jvar} '.ltm.nc'],[varNames{jvar} 'ClmSm']);
  for jlev = [3 6 9 10];
%   figure(1)
%   clf
  for jmo = [1 2 6 7 8]%1:12
%   subplot(3,4,jmo)
   figure('Visible','Off')
%   figure(1)
   clf
   fld = double(squeeze(mean(theVar(:,:,jlev,find(mm==jmo)),4)));
   if jvar < 3
%      clevs = prctile(abs(fld(:)),95)*linspace(-1,1,nc);
      switch jlev
        case 3 % 850mb
         clevs = 10*linspace(-1,1,nc);
        case 6 % 500mb
         clevs = 20*linspace(-1,1,nc);
        case 9 % 250mb
         clevs = 30*linspace(-1,1,nc);
        case 10 % 200mb
         clevs = 30*linspace(-1,1,nc);
      end
      cmap = (flipud(lbmap(nc,'redblue')));
      cmap(ceil(nc/2),:) = [1 1 1];
   else
      clevs = linspace(min(fld(:)),max(fld(:)),nc);
      cmap = (flipud(lbmap(nc,'redblue')));
   end
   colormap(cmap)
   m_proj('miller','lon',[0 360]);
   [ha,hb] = m_contourf(lon,lat,fld',clevs);
%   shading flat
   set(hb,'edgecolor','none')
   caxis([min(clevs) max(clevs)])
   hold on
   m_grid('box','fancy')
   m_coast('color',[0 0 0]);
%   if jvar < 3
%      caxis(prctile(abs(fld(:)),95)*[-1 1])
%   end
   colorbar
   title([varNames{jvar} ', ' num2str(level(jlev)) ' mb (month = ' num2str(jmo) ')'])
%   export_fig(['../figures/' varNames{jvar} '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.pdf'])
   drawnow
   print('-dpsc',['../figures/' 'special_' varNames{jvar} '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.eps'])
   close all
  end
  end

end
end



% Wave activity flux climos...
clear

set_paths
% loads TN2001path and basepath
% ltm files are in basepath/var/var.ltm.nc, where var == air, hgt, uwnd, or vwnd. 366-day climos.
% Monthly climatologies of the WAF stuff are in basepath/derived/misc/TN2001.var.ClmMon.nc, where var == Fx, Fy, Fz, psidev, NN.

% Load and make u, v, hgt climatologies at select levels
%   (level = 1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10)
level = ncread([TN2001path 'TN2001.Fx.ClmMon.nc'],'level');
lat = ncread([TN2001path 'TN2001.Fx.ClmMon.nc'],'lat');
lon = ncread([TN2001path 'TN2001.Fx.ClmMon.nc'],'lon');

nc = 21;
cmap = (flipud(lbmap(nc,'redblue')));
cmap(ceil(nc/2),:) = [1 1 1];

if 0
varNames = {'Fx','Fy','Fz','psidev','NN'};
for jvar = 1:length(varNames)
   theVar = ncread([TN2001path 'TN2001.' varNames{jvar} '.ClmMon.nc'],[varNames{jvar} 'Clm']);
   for jlev = [3 6 10]
       for jmo = 1:12
        figure(1)
        clf
        fld = double(squeeze(theVar(:,:,jlev,jmo)));
        if jvar < 5
           clevs = prctile(abs(fld(:)),95)*linspace(-1,1,nc);
           cmap = (flipud(lbmap(nc,'redblue')));
           cmap(ceil(nc/2),:) = [1 1 1];
        else
           clevs = linspace(min(fld(:)),max(fld(:)),nc);
           cmap = (flipud(lbmap(nc,'redblue')));
        end
        colormap(cmap)
        m_proj('miller','lon',[0 360]);
        [ha,hb] = m_contourf(lon,lat,fld',clevs);
        set(hb,'edgecolor','none')
        caxis([min(clevs) max(clevs)])
        hold on
        m_grid('box','fancy')
        m_coast('color',[0 0 0]);
        colorbar
        title([varNames{jvar} ', ' num2str(level(jlev)) ' mb (month = ' num2str(jmo) ')'])
        drawnow
        print('-dpsc',['../figures/' varNames{jvar} '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.eps'])
        close all
       end
   end

end
end

if 0

   
   Fx = ncread([TN2001path 'TN2001.Fx.ClmMon.nc'],'FxClm');
   Fy = ncread([TN2001path 'TN2001.Fy.ClmMon.nc'],'FyClm');
   Fz = ncread([TN2001path 'TN2001.Fz.ClmMon.nc'],'FzClm');
   psidev = ncread([TN2001path 'TN2001.psidev.ClmMon.nc'],'psidevClm');
   NN = ncread([TN2001path 'TN2001.NN.ClmMon.nc'],'NNClm');
   uwnd = ncread([basepath '/uwnd/uwnd.ltm.nc'],'uwndClmSm');
   dayNums = 1:366;
   dates = datenum(2012,1,1) + dayNums - 1;
   [~,mm,~,~,~,~] = datevec(dates);
   for jlev = [3 6 10]
       for jmo = 1:12
        figure('Visible','Off')
        clf
        fldx = double(squeeze(Fx(:,:,jlev,jmo)));
        fldy = double(squeeze(Fy(:,:,jlev,jmo)));
        fldz = double(squeeze(Fz(:,:,jlev,jmo)));
        fldu = double(squeeze(mean(uwnd(:,:,jlev,find(mm==jmo)),4)));
        umask = NaN(size(fldu));
        uthresh = 2;
        umask(fldu>=uthresh) = 1;
        clevs = prctile(abs(fldz(:)),95)*linspace(-1,1,nc);
        cmap = (flipud(lbmap(nc,'redblue')));
        cmap(ceil(nc/2),:) = [1 1 1];
        colormap(cmap)
        m_proj('miller','lon',[0 360]);
        [ha,hb] = m_contourf(lon,lat,umask'.*fldz',clevs);
        set(hb,'edgecolor','none')
	caxis([min(clevs) max(clevs)])
        hold on
        [LON,LAT] = meshgrid(lon,lat);
        incr = 3;
        vscalefac = 0.5;
        h=m_quiver(LON(1:incr:end,1:incr:end),LAT(1:incr:end,1:incr:end),vscalefac*umask(1:incr:end,1:incr:end)'.*fldx(1:incr:end,1:incr:end)',vscalefac*fldy(1:incr:end,1:incr:end)');
        set(h,'AutoScale','off')
%        set(h,'AutoScaleFactor',2)
        set(h,'color',[.3 .3 .3])
        set(h,'LineWidth',1)
        %caxis([min(clevs) max(clevs)])
        m_grid('box','fancy')
        m_coast('color',[0 0 0]);
        colorbar
        title(['Wave Activity Flux, ' num2str(level(jlev)) ' mb (month = ' num2str(jmo) ')'])
        drawnow
        print('-dpsc',['../figures/WAF.u' num2str(uthresh) '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.eps'])
        close all
       end
   end


end

if 0


   Fx = ncread([TN2001path 'TN2001.Fx.ClmMon.nc'],'FxClm');
   Fy = ncread([TN2001path 'TN2001.Fy.ClmMon.nc'],'FyClm');
   DivF = ncread([TN2001path 'TN2001.DivF.ClmMon.nc'],'DivFClm');
   psidev = ncread([TN2001path 'TN2001.psidev.ClmMon.nc'],'psidevClm');
   NN = ncread([TN2001path 'TN2001.NN.ClmMon.nc'],'NNClm');
   uwnd = ncread([basepath '/uwnd/uwnd.ltm.nc'],'uwndClmSm');
   dayNums = 1:366;
   dates = datenum(2012,1,1) + dayNums - 1;
   [~,mm,~,~,~,~] = datevec(dates);
   for jlev = [3 6 10]
       for jmo = 1:12
        figure('Visible','Off')
        clf
        fldx = double(squeeze(Fx(:,:,jlev,jmo)));
        fldy = double(squeeze(Fy(:,:,jlev,jmo)));
	fldz = double(squeeze(DivF(:,:,jlev,jmo)));
	fldu = double(squeeze(mean(uwnd(:,:,jlev,find(mm==jmo)),4)));
        umask = NaN(size(fldu));
	uthresh = 2;
	umask(fldu>=uthresh) = 1;
        clevs = prctile(abs(fldz(:)),95)*linspace(-1,1,nc);
	cmap = (flipud(lbmap(nc,'redblue')));
	cmap(ceil(nc/2),:) = [1 1 1];
	colormap(cmap)
	m_proj('miller','lon',[0 360]);
	[ha,hb] = m_contourf(lon,lat,umask'.*fldz',clevs);
        set(hb,'edgecolor','none')
	caxis([min(clevs) max(clevs)])
	hold on
        [LON,LAT] = meshgrid(lon,lat);
        incr = 3;
        vscalefac = 0.5;
        h=m_quiver(LON(1:incr:end,1:incr:end),LAT(1:incr:end,1:incr:end),vscalefac*umask(1:incr:end,1:incr:end)'.*fldx(1:incr:end,1:incr:end)',vscalefac*fldy(1:incr:end,1:incr:end)');
        set(h,'AutoScale','off')
%        set(h,'AutoScaleFactor',2)
        set(h,'color',[.3 .3 .3])
        set(h,'LineWidth',1)
        %caxis([min(clevs) max(clevs)])
        m_grid('box','fancy')
        m_coast('color',[0 0 0]);
        colorbar
        title(['Wave Activity Flux, ' num2str(level(jlev)) ' mb (month = ' num2str(jmo) ')'])
        drawnow
        print('-dpsc',['../figures/WAFdivF.u' num2str(uthresh) '.' num2str(level(jlev)) 'mb.' num2str(jmo) '.eps'])
        close all
       end
   end


end
