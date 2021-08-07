function x = loadPic(picNum)     % Load picture
picSearchString = sprintf('p%04d*.mat', picNum);
picMATFile = dir(picSearchString);
if (~isempty(picMATFile))
   x=load(picMATFile.name);
   x=x.data;
else
   error = sprintf('Picture file p%04d*.m not found.', picNum)
   x = [];
   return;
end
