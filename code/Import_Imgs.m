for k = 30:30
  folderdir = '../..//DataSet/Training/UA-DETRAC/Insight-MVT_Annotation_Train/MVI_20034/';
  jpgFilename = sprintf('img0%04d.jpg', k);
  fullFileName = fullfile(folderdir, jpgFilename);
  imageData = imread(fullFileName );
  cd RSWHE-M;
  outputimage = RSWHE_M_TOP(imageData,8, 0);
%   outputimage = CLAHE(imageData);
  cd ../Hist_Output;
  imwrite(outputimage, jpgFilename);
  cd ..;
end