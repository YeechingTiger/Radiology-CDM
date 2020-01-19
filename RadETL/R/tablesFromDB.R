library(DatabaseConnector)
library(dplyr)
connectionDetails <- createConnectionDetails(dbms="sql server", 
                                             server="128.1.99.58",
                                             user="",
                                             password="",
                                             schema="ID_XYLITOL_WHITE")
conn <- connect(connectionDetails)
RadiologyImageTable<-querySql(conn,"SELECT TOP (1000) [Filepath]
      ,[ImageID]
      ,[SeriesID]
      ,[RadiologyOccurrenceID]
      ,[PatientID]
      ,[ImageResolutionRows]
      ,[ImageResolutionColumns]
      ,[SliceThickness]
      ,[SeriesDescription]
  FROM [ID_XYLITOL_WHITE].[dbo].[importantDICOMheader]")
colnames(RadiologyImageTable)<-c('filepath', 'Image_ID', 'Series_ID', 'Radiology_Occurrence_ID', 'Patient_ID', 'Image_Resolution_Rows', 'Image_Resolution_Columns', 'Image_Slice_Thickness', 'Radiology_Phase_Concept_ID')
RadiologyImageTable<-RadiologyImageTable%>%dplyr::group_by(Radiology_Occurrence_ID, Series_ID)%>%dplyr::mutate(Image_No=row_number())
RadiologyImageTable<-RadiologyImageTable%>%dplyr::group_by(Radiology_Occurrence_ID, Series_ID)%>%dplyr::mutate(Phase_Total_No=n())

RadiologyOccurrenceTable<-querySql(conn,"SELECT TOP (1000) [RadiologyOccurrenceID]
      ,[StudyDate]
      ,[StudyTime]
      ,[PatientID]
      ,[Manufacturer]
      ,[Modality]
      ,[ProtocolName]
      ,[PerformedProcedureStepDescription]
      ,[BodyPartExamined]
      ,[StudyDescription]
  FROM [ID_XYLITOL_WHITE].[dbo].[importantDICOMheader]")

colnames(RadiologyOccurrenceTable)<-c('Radiology_Occurrence_ID', 'StudyDate', 'StudyTime', 'Patient_ID', 'Manufacturer', 'Modality', 'ProtocolName', 'PerformedProcedureStepDescription', 'BodyPartExamined', 'StudyDescription')

RadiologyOccurrenceTable<-RadiologyOccurrenceTable%>%dplyr::group_by(Radiology_Occurrence_ID)%>%dplyr::mutate(Image_Total_No=n())
RadiologyOccurrenceTable['StudyTime']<-sapply(RadiologyOccurrenceTable['StudyTime'], function(x) ifelse(x=='NA', '', x))
RadiologyOccurrenceTable<-RadiologyOccurrenceTable%>%dplyr::mutate(Radiology_Occurrence_DateTime=ifelse(is.na(as.POSIXct(gsub('NA', '', paste(StudyDate, StudyTime)), format = '%Y%m%d%H%M%S',origin = "1970-01-01",tz ="UTC"))==F, as.character(as.POSIXct(gsub('NA', '', paste(StudyDate, StudyTime)), format = '%Y%m%d%H%M%S',origin = "1970-01-01",tz ="UTC")), ifelse(is.na(as.POSIXct(gsub('NA', '', paste(StudyDate, StudyTime)), format = '%Y%m%d',origin = "1970-01-01",tz ="UTC"))==F, as.character(as.POSIXct(studyDate, format = '%Y%m%d',origin = "1970-01-01",tz ="UTC")), 'NA')))
RadiologyOccurrenceTable<-RadiologyOccurrenceTable[, c(1, 4:12)]
RadiologyOccurrenceTable<-RadiologyOccurrenceTable[!duplicated(RadiologyOccurrenceTable$Radiology_Occurrence_ID),]
View(RadiologyOccurrenceTable)
