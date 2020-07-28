### Windows Search ###

**[Powershell script](https://github.com/kacos2000/Win10/blob/master/Cortana/Cortana_AppCache.ps1)** to parse AppCache?????????????.txt files in either:<br>
  '$env:LOCALAPPDATA"\Packages\ **Microsoft.Windows.Cortana_cw5n1h2txyewy** \LocalState\DeviceSearchCache\' or <br>
  '$env:LOCALAPPDATA"\Packages\ **Microsoft.Windows.Search_cw5n1h2txyewy** \LocalState\DeviceSearchCache\' folders <br>

  ![sample_output](https://raw.githubusercontent.com/kacos2000/Win10/master/Cortana/C_AppCache.JPG)

  **NOTE:** The 'Type,Name,Path,Description' (Jumplist) fields are from the recently used list/history of the respective app if Type = 1!<br>
  as seen in the search Window:<br>
  
  ![SW](https://raw.githubusercontent.com/kacos2000/Win10/master/Cortana/ln.JPG)


**A brief look at '$env:LOCALAPPDATA"\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AppData\Indexed DB\IndexedDB.edb**
   
   The (**T2**) table seems to contain similar info to AppCache*.txt, but in a BLOB:<br>
   
 ```    <Row>
        <Column Name="autoIncObjectCount" Value="1870"/>
        <Column Name="dataBlob" Value="AAAAARsAAAAWAAAATABhAHMAdABVAHAAZABhAHQAZQBkAAAABgAAAAybHl8wAAAAUwB1AGcAZwBlAHMAdABpAG8AbgBFAG4AZwBhAGcAZQBtAGUAbgB0AEQAYQB0AGEAGwAAAKYAAAAzADYACQB7ADEAQQBDADEANABFADcANwAtADAAMgBFADcALQA0AEUANQBEAC0AQgA3ADQANAAtADIARQBCADEAQQBFADUAMQA5ADgAQgA3AH0AXABXAGkAbgBkAG8AdwBzAFAAbwB3AGUAcgBTAGgAZQBsAGwAXAB2ADEALgAwAFwAUABvAHcAZQByAFMAaABlAGwAbABfAEkAUwBFAC4AZQB4AGUAAAAbAAAAIgAAAHAAcgBlAGYAaQB4AEwAYQB1AG4AYwBoAEMAbwB1AG4AdAAAAAYAAAAYAAAAHAAAAGwAYQBzAHQATABhAHUAbgBjAGgAVABpAG0AZQAGAAAADJseXxIAAABnAHIAbwB1AHAAVAB5AHAAZQAAAAYAAAAkAAAA////////////////"/>
        <Column Name="I-1-Date"/>
        <Column Name="I-1-Number"/>
        <Column Name="I-1-String"/>
        <Column Name="I-1-VariantType" Value="4"/>
        <Column Name="I-2-Date"/>
        <Column Name="I-2-Number" Value="1595841292"/>
        <Column Name="I-2-String"/>
        <Column Name="I-2-VariantType" Value="1"/>
      </Row> 
 ```

Decoded from Base64, the dataBlob looks like:
    ```
    [System.Text.Encoding]::utf8.GetString([System.Convert]::FromBase64String($dataBlob))
             L a s t U p d a t e d      �_0   S u g g e s t i o n E n g a g e m e n t D a t a    �   3 6 	 { 1 A C 1 4 E 7 7 - 0 2 E 7 - 4 E 5 D - B 7 4 4 - 2 E B 1 A E 5 1 9 8 B 7 } \ W i n d o w s P o w
     e r S h e l l \ v 1 . 0 \ P o w e r S h e l l _ I S E . e x e      "   p r e f i x L a u n c h C o u n t            l a s t L a u n c h T i m e    �_   g r o u p T y p e      $ 
     ```



**A brief look at Win10 Windows.edb**

the last table of the known database (**SystemIndex_PropertyStore**) is a Gold Mine and a pain in the @ to extract:

```    <Row>
      <Column Name="0F-InvertedOnlyMD5" Value="FDSYOylCiDiD1Qq+R+1dGQ==" />
      <Column Name="0-InvertedOnlyPids" Value="KRJ8Eg==" />
      <Column Name="11-System_FileName" Value="Start Menu" />
      <Column Name="13F-System_Size" />
      <Column Name="14F-System_FileAttributes" Value="8209" />
      <Column Name="15F-System_DateModified" Value="eEj592xh1gE=" />
      <Column Name="16F-System_DateCreated" Value="/N2ljNlc1gE=" />
      <Column Name="17F-System_DateAccessed" Value="RySX0xRh1gE=" />
      <Column Name="22-System_FileFRN" />
      <Column Name="27F-System_Search_Rank" />
      <Column Name="28-System_Search_HitCount" />
      <Column Name="33-System_ItemUrl" Value="file:C:/ProgramData/Microsoft/Windows/Start Menu" />
      <Column Name="34-System_ContentUrl" />
      <Column Name="3-System_ItemFolderNameDisplay" Value="Windows" />
      <Column Name="4096-Microsoft_OneNote_LinkedNoteUri" />
      <Column Name="4097-Microsoft_OneNote_PageEditHistory" />
      <Column Name="4098-Microsoft_OneNote_TaggedNotes" />
      <Column Name="4099-Microsoft_Visio_MastersDetails" />
      <Column Name="4100-Microsoft_Visio_MastersKeywords" />
      <Column Name="4101-System_AcquisitionID" />
      <Column Name="4102-System_Activity_AccountId" />
      <Column Name="4103-System_Activity_ActivationUri" />
      <Column Name="4104-System_Activity_ActivityId" />
      <Column Name="4105-System_Activity_AppDisplayName" />
      <Column Name="4106-System_Activity_AppIdKind" />
      <Column Name="4107-System_Activity_AppIdList" />
      <Column Name="4108-System_Activity_AppImageUri" />
      <Column Name="4109-System_Activity_AttributionName" />
      <Column Name="4110-System_Activity_BackgroundColor" />
      <Column Name="4111-System_Activity_ContentImageUri" />
      <Column Name="4112-System_Activity_ContentUri" />
      <Column Name="4113-System_Activity_ContentVisualPropertiesHash" />
      <Column Name="4114-System_Activity_Description" />
      <Column Name="4115-System_Activity_DisplayText" />
      <Column Name="4116-System_Activity_FallbackUri" />
      <Column Name="4117-System_Activity_HasAdaptiveContent" />
      <Column Name="4118-System_Activity_SetCategory" />
      <Column Name="4119-System_Activity_SetId" />
      <Column Name="4120-System_ActivityHistory_ActiveDays" />
      <Column Name="4121-System_ActivityHistory_ActiveDuration" />
      <Column Name="4122-System_ActivityHistory_AppActivityId" />
      <Column Name="4123-System_ActivityHistory_AppId" />
      <Column Name="4124-System_ActivityHistory_DaysActive" />
      <Column Name="4125-System_ActivityHistory_DeviceId" />
      <Column Name="4126-System_ActivityHistory_DeviceMake" />
      <Column Name="4127-System_ActivityHistory_DeviceModel" />
      <Column Name="4128-System_ActivityHistory_DeviceName" />
      <Column Name="4129-System_ActivityHistory_DeviceType" />
      <Column Name="4130-System_ActivityHistory_EndTime" />
      <Column Name="4131-System_ActivityHistory_HoursActive" />
      <Column Name="4132-System_ActivityHistory_Id" />
      <Column Name="4133-System_ActivityHistory_Importance" />
      <Column Name="4134-System_ActivityHistory_IsHistoryAttributedToSetAnchor" />
      <Column Name="4135-System_ActivityHistory_IsLocal" />
      <Column Name="4136-System_ActivityHistory_LocalEndTime" />
      <Column Name="4137-System_ActivityHistory_LocalStartTime" />
      <Column Name="4138-System_ActivityHistory_LocationActivityId" />
      <Column Name="4139-System_ActivityHistory_StartTime" />
      <Column Name="4140-System_Address_Country" />
      <Column Name="4141-System_Address_CountryCode" />
      <Column Name="4142-System_Address_Region" />
      <Column Name="4143-System_Address_RegionCode" />
      <Column Name="4144-System_Address_Town" />
      <Column Name="4145-System_AppUserModel_ActivationContext" />
      <Column Name="4146-System_AppUserModel_PackageFamilyName" />
      <Column Name="4147-System_AppUserModel_RelaunchIconResource" />
      <Column Name="4148-System_ApplicationName" />
      <Column Name="4149-System_Audio_ChannelCount" />
      <Column Name="4150-System_Audio_EncodingBitrate" />
      <Column Name="4151-System_Audio_Format" />
      <Column Name="4152-System_Audio_PeakValue" />
      <Column Name="4153-System_Audio_SampleRate" />
      <Column Name="4154-System_Audio_SampleSize" />
      <Column Name="4155-System_Author" />
      <Column Name="4156-System_Calendar_Duration" />
      <Column Name="4157-System_Calendar_IsOnline" />
      <Column Name="4158-System_Calendar_IsRecurring" />
      <Column Name="4159-System_Calendar_Location" />
      <Column Name="4160-System_Calendar_OptionalAttendeeAddresses" />
      <Column Name="4161-System_Calendar_OptionalAttendeeNames" />
      <Column Name="4162-System_Calendar_OrganizerAddress" />
      <Column Name="4163-System_Calendar_OrganizerName" />
      <Column Name="4164-System_Calendar_ReminderTime" />
      <Column Name="4165-System_Calendar_RequiredAttendeeAddresses" />
      <Column Name="4166-System_Calendar_RequiredAttendeeNames" />
      <Column Name="4167-System_Calendar_Resources" />
      <Column Name="4168-System_Calendar_ResponseStatus" />
      <Column Name="4169-System_Calendar_ShowTimeAs" />
      <Column Name="4170-System_Calendar_ShowTimeAsText" />
      <Column Name="4171-System_CameraRollDeduplicationId" />
      <Column Name="4172-System_Category" />
      <Column Name="4173-System_Comment" />
      <Column Name="4174-System_Communication_AccountName" />
      <Column Name="4175-System_Communication_DateItemExpires" />
      <Column Name="4176-System_Communication_Direction" />
      <Column Name="4177-System_Communication_FollowupIconIndex" />
      <Column Name="4178-System_Communication_HeaderItem" />
      <Column Name="4179-System_Communication_PolicyTag" />
      <Column Name="4180-System_Communication_SecurityFlags" />
      <Column Name="4181-System_Communication_TaskStatus" />
      <Column Name="4182-System_Communication_TaskStatusText" />
      <Column Name="4183-System_Company" />
      <Column Name="4184-System_ComputerName" />
      <Column Name="4185-System_ConnectedSearch_ApplicationSearchScope" />
      <Column Name="4186-System_ConnectedSearch_FallbackTemplate" />
      <Column Name="4187-System_ConnectedSearch_ItemSource" />
      <Column Name="4188-System_ConnectedSearch_JumpList" />
      <Column Name="4189-System_ConnectedSearch_LocalWeights" />
      <Column Name="4190-System_ConnectedSearch_RenderingTemplate" />
      <Column Name="4191-System_ConnectedSearch_Type" />
      <Column Name="4192-System_ConnectedSearch_VoiceCommandExamples" />
      <Column Name="4193-System_Contact_AccountPictureDynamicVideo" />
      <Column Name="4194-System_Contact_AccountPictureLarge" />
      <Column Name="4195-System_Contact_AccountPictureSmall" />
      <Column Name="4196-System_Contact_Anniversary" />
      <Column Name="4197-System_Contact_AssistantName" />
      <Column Name="4198-System_Contact_AssistantTelephone" />
      <Column Name="4199-System_Contact_Birthday" />
      <Column Name="4200-System_Contact_BusinessAddress" />
      <Column Name="4201-System_Contact_BusinessAddress1Country" />
      <Column Name="4202-System_Contact_BusinessAddress1Locality" />
      <Column Name="4203-System_Contact_BusinessAddress1PostalCode" />
      <Column Name="4204-System_Contact_BusinessAddress1Region" />
      <Column Name="4205-System_Contact_BusinessAddress1Street" />
      <Column Name="4206-System_Contact_BusinessAddress2Country" />
      <Column Name="4207-System_Contact_BusinessAddress2Locality" />
      <Column Name="4208-System_Contact_BusinessAddress2PostalCode" />
      <Column Name="4209-System_Contact_BusinessAddress2Region" />
      <Column Name="4210-System_Contact_BusinessAddress2Street" />
      <Column Name="4211-System_Contact_BusinessAddress3Country" />
      <Column Name="4212-System_Contact_BusinessAddress3Locality" />
      <Column Name="4213-System_Contact_BusinessAddress3PostalCode" />
      <Column Name="4214-System_Contact_BusinessAddress3Region" />
      <Column Name="4215-System_Contact_BusinessAddress3Street" />
      <Column Name="4216-System_Contact_BusinessAddressCity" />
      <Column Name="4217-System_Contact_BusinessAddressCountry" />
      <Column Name="4218-System_Contact_BusinessAddressPostOfficeBox" />
      <Column Name="4219-System_Contact_BusinessAddressPostalCode" />
      <Column Name="4220-System_Contact_BusinessAddressState" />
      <Column Name="4221-System_Contact_BusinessAddressStreet" />
      <Column Name="4222-System_Contact_BusinessEmailAddresses" />
      <Column Name="4223-System_Contact_BusinessFaxNumber" />
      <Column Name="4224-System_Contact_BusinessHomePage" />
      <Column Name="4225-System_Contact_BusinessTelephone" />
      <Column Name="4226-System_Contact_CallbackTelephone" />
      <Column Name="4227-System_Contact_CarTelephone" />
      <Column Name="4228-System_Contact_Children" />
      <Column Name="4229-System_Contact_CompanyMainTelephone" />
      <Column Name="4230-System_Contact_ConnectedServiceDisplayName" />
      <Column Name="4231-System_Contact_ConnectedServiceIdentities" />
      <Column Name="4232-System_Contact_ConnectedServiceName" />
      <Column Name="4233-System_Contact_ConnectedServiceSupportedActions" />
      <Column Name="4234-System_Contact_DataSuppliers" />
      <Column Name="4235-System_Contact_Department" />
      <Column Name="4236-System_Contact_DisplayBusinessPhoneNumbers" />
      <Column Name="4237-System_Contact_DisplayHomePhoneNumbers" />
      <Column Name="4238-System_Contact_DisplayMobilePhoneNumbers" />
      <Column Name="4239-System_Contact_DisplayOtherPhoneNumbers" />
      <Column Name="4240-System_Contact_EmailAddress" />
      <Column Name="4241-System_Contact_EmailAddress2" />
      <Column Name="4242-System_Contact_EmailAddress3" />
      <Column Name="4243-System_Contact_EmailAddresses" />
      <Column Name="4244-System_Contact_EmailName" />
      <Column Name="4245-System_Contact_FileAsName" />
      <Column Name="4246-System_Contact_FirstName" />
      <Column Name="4247-System_Contact_FullName" />
      <Column Name="4248-System_Contact_Gender" />
      <Column Name="4249-System_Contact_GenderValue" />
      <Column Name="4250-System_Contact_Hobbies" />
      <Column Name="4251-System_Contact_HomeAddress" />
      <Column Name="4252-System_Contact_HomeAddress1Country" />
      <Column Name="4253-System_Contact_HomeAddress1Locality" />
      <Column Name="4254-System_Contact_HomeAddress1PostalCode" />
      <Column Name="4255-System_Contact_HomeAddress1Region" />
      <Column Name="4256-System_Contact_HomeAddress1Street" />
      <Column Name="4257-System_Contact_HomeAddress2Country" />
      <Column Name="4258-System_Contact_HomeAddress2Locality" />
      <Column Name="4259-System_Contact_HomeAddress2PostalCode" />
      <Column Name="4260-System_Contact_HomeAddress2Region" />
      <Column Name="4261-System_Contact_HomeAddress2Street" />
      <Column Name="4262-System_Contact_HomeAddress3Country" />
      <Column Name="4263-System_Contact_HomeAddress3Locality" />
      <Column Name="4264-System_Contact_HomeAddress3PostalCode" />
      <Column Name="4265-System_Contact_HomeAddress3Region" />
      <Column Name="4266-System_Contact_HomeAddress3Street" />
      <Column Name="4267-System_Contact_HomeAddressCity" />
      <Column Name="4268-System_Contact_HomeAddressCountry" />
      <Column Name="4269-System_Contact_HomeAddressPostOfficeBox" />
      <Column Name="4270-System_Contact_HomeAddressPostalCode" />
      <Column Name="4271-System_Contact_HomeAddressState" />
      <Column Name="4272-System_Contact_HomeAddressStreet" />
      <Column Name="4273-System_Contact_HomeEmailAddresses" />
      <Column Name="4274-System_Contact_HomeFaxNumber" />
      <Column Name="4275-System_Contact_HomeTelephone" />
      <Column Name="4276-System_Contact_IMAddress" />
      <Column Name="4277-System_Contact_JA_CompanyNamePhonetic" />
      <Column Name="4278-System_Contact_JA_FirstNamePhonetic" />
      <Column Name="4279-System_Contact_JA_LastNamePhonetic" />
      <Column Name="4280-System_Contact_JobInfo1CompanyAddress" />
      <Column Name="4281-System_Contact_JobInfo1CompanyName" />
      <Column Name="4282-System_Contact_JobInfo1Department" />
      <Column Name="4283-System_Contact_JobInfo1Manager" />
      <Column Name="4284-System_Contact_JobInfo1OfficeLocation" />
      <Column Name="4285-System_Contact_JobInfo1Title" />
      <Column Name="4286-System_Contact_JobInfo1YomiCompanyName" />
      <Column Name="4287-System_Contact_JobInfo2CompanyAddress" />
      <Column Name="4288-System_Contact_JobInfo2CompanyName" />
      <Column Name="4289-System_Contact_JobInfo2Department" />
      <Column Name="4290-System_Contact_JobInfo2Manager" />
      <Column Name="4291-System_Contact_JobInfo2OfficeLocation" />
      <Column Name="4292-System_Contact_JobInfo2Title" />
      <Column Name="4293-System_Contact_JobInfo2YomiCompanyName" />
      <Column Name="4294-System_Contact_JobInfo3CompanyAddress" />
      <Column Name="4295-System_Contact_JobInfo3CompanyName" />
      <Column Name="4296-System_Contact_JobInfo3Department" />
      <Column Name="4297-System_Contact_JobInfo3Manager" />
      <Column Name="4298-System_Contact_JobInfo3OfficeLocation" />
      <Column Name="4299-System_Contact_JobInfo3Title" />
      <Column Name="4300-System_Contact_JobInfo3YomiCompanyName" />
      <Column Name="4301-System_Contact_JobTitle" />
      <Column Name="4302-System_Contact_Label" />
      <Column Name="4303-System_Contact_LastName" />
      <Column Name="4304-System_Contact_MailingAddress" />
      <Column Name="4305-System_Contact_MiddleName" />
      <Column Name="4306-System_Contact_MobileTelephone" />
      <Column Name="4307-System_Contact_NickName" />
      <Column Name="4308-System_Contact_OfficeLocation" />
      <Column Name="4309-System_Contact_OtherAddress" />
      <Column Name="4310-System_Contact_OtherAddress1Country" />
      <Column Name="4311-System_Contact_OtherAddress1Locality" />
      <Column Name="4312-System_Contact_OtherAddress1PostalCode" />
      <Column Name="4313-System_Contact_OtherAddress1Region" />
      <Column Name="4314-System_Contact_OtherAddress1Street" />
      <Column Name="4315-System_Contact_OtherAddress2Country" />
      <Column Name="4316-System_Contact_OtherAddress2Locality" />
      <Column Name="4317-System_Contact_OtherAddress2PostalCode" />
      <Column Name="4318-System_Contact_OtherAddress2Region" />
      <Column Name="4319-System_Contact_OtherAddress2Street" />
      <Column Name="4320-System_Contact_OtherAddress3Country" />
      <Column Name="4321-System_Contact_OtherAddress3Locality" />
      <Column Name="4322-System_Contact_OtherAddress3PostalCode" />
      <Column Name="4323-System_Contact_OtherAddress3Region" />
      <Column Name="4324-System_Contact_OtherAddress3Street" />
      <Column Name="4325-System_Contact_OtherAddressCity" />
      <Column Name="4326-System_Contact_OtherAddressCountry" />
      <Column Name="4327-System_Contact_OtherAddressPostOfficeBox" />
      <Column Name="4328-System_Contact_OtherAddressPostalCode" />
      <Column Name="4329-System_Contact_OtherAddressState" />
      <Column Name="4330-System_Contact_OtherAddressStreet" />
      <Column Name="4331-System_Contact_OtherEmailAddresses" />
      <Column Name="4332-System_Contact_PagerTelephone" />
      <Column Name="4333-System_Contact_PersonalTitle" />
      <Column Name="4334-System_Contact_PhoneNumbersCanonical" />
      <Column Name="4335-System_Contact_Prefix" />
      <Column Name="4336-System_Contact_PrimaryAddressCity" />
      <Column Name="4337-System_Contact_PrimaryAddressCountry" />
      <Column Name="4338-System_Contact_PrimaryAddressPostOfficeBox" />
      <Column Name="4339-System_Contact_PrimaryAddressPostalCode" />
      <Column Name="4340-System_Contact_PrimaryAddressState" />
      <Column Name="4341-System_Contact_PrimaryAddressStreet" />
      <Column Name="4342-System_Contact_PrimaryEmailAddress" />
      <Column Name="4343-System_Contact_PrimaryTelephone" />
      <Column Name="4344-System_Contact_Profession" />
      <Column Name="4345-System_Contact_SpouseName" />
      <Column Name="4346-System_Contact_Suffix" />
      <Column Name="4347-System_Contact_TTYTDDTelephone" />
      <Column Name="4348-System_Contact_TelexNumber" />
      <Column Name="4349-System_Contact_WebPage" />
      <Column Name="4350-System_Contact_Webpage2" />
      <Column Name="4351-System_Contact_Webpage3" />
      <Column Name="4352-System_ContentStatus" />
      <Column Name="4353-System_ContentType" />
      <Column Name="4355-System_Copyright" />
      <Column Name="4356-System_CreatorAppId" />
      <Column Name="4357-System_CreatorOpenWithUIOptions" />
      <Column Name="4358-System_DRM_IsDisabled" />
      <Column Name="4359-System_DRM_IsProtected" />
      <Column Name="4361-System_DateAcquired" />
      <Column Name="4362-System_DateArchived" />
      <Column Name="4363-System_DateCompleted" />
      <Column Name="4365-System_DateImported" Value="AOUpjdlc1gE=" />
      <Column Name="4367-System_Document_ByteCount" />
      <Column Name="4368-System_Document_CharacterCount" />
      <Column Name="4369-System_Document_ClientID" />
      <Column Name="4370-System_Document_Contributor" />
      <Column Name="4371-System_Document_DateCreated" Value="AOUpjdlc1gE=" />
      <Column Name="4372-System_Document_DatePrinted" />
      <Column Name="4373-System_Document_DateSaved" Value="eEj592xh1gE=" />
      <Column Name="4374-System_Document_Division" />
      <Column Name="4375-System_Document_DocumentID" />
      <Column Name="4376-System_Document_HiddenSlideCount" />
      <Column Name="4377-System_Document_LastAuthor" />
      <Column Name="4378-System_Document_LineCount" />
      <Column Name="4379-System_Document_Manager" />
      <Column Name="4380-System_Document_PageCount" />
      <Column Name="4381-System_Document_ParagraphCount" />
      <Column Name="4382-System_Document_PresentationFormat" />
      <Column Name="4383-System_Document_RevisionNumber" />
      <Column Name="4384-System_Document_SlideCount" />
      <Column Name="4385-System_Document_TotalEditingTime" />
      <Column Name="4386-System_Document_Version" />
      <Column Name="4387-System_Document_WordCount" />
      <Column Name="4388-System_DueDate" />
      <Column Name="4389-System_EndDate" />
      <Column Name="4392-System_FileExtension" />
      <Column Name="4395-System_FileOfflineAvailabilityStatus" />
      <Column Name="4396-System_FileOwner" />
      <Column Name="4397-System_FilePlaceholderStatus" Value="6" />
      <Column Name="4398-System_FlagColor" />
      <Column Name="4399-System_FlagColorText" />
      <Column Name="4400-System_FlagStatus" />
      <Column Name="4401-System_FlagStatusText" />
      <Column Name="4402-System_FolderKind" />
      <Column Name="4403-System_FolderNameDisplay" Value="Start Menu" />
      <Column Name="4404-System_GPS_Date" />
      <Column Name="4405-System_GPS_Latitude" />
      <Column Name="4406-System_GPS_LatitudeDecimal" />
      <Column Name="4407-System_GPS_LatitudeRef" />
      <Column Name="4408-System_GPS_Longitude" />
      <Column Name="4409-System_GPS_LongitudeDecimal" />
      <Column Name="4410-System_GPS_LongitudeRef" />
      <Column Name="4411-System_HighKeywords" />
      <Column Name="4412-System_History_SelectionCount" />
      <Column Name="4413-System_History_TargetUrlHostName" />
      <Column Name="4414-System_History_VisitCount" />
      <Column Name="4415-System_IconIndex" />
      <Column Name="4416-System_Identity" />
      <Column Name="4417-System_Image_BitDepth" />
      <Column Name="4418-System_Image_Compression" />
      <Column Name="4419-System_Image_CompressionText" />
      <Column Name="4420-System_Image_Dimensions" />
      <Column Name="4421-System_Image_HorizontalResolution" />
      <Column Name="4422-System_Image_HorizontalSize" />
      <Column Name="4423-System_Image_VerticalResolution" />
      <Column Name="4424-System_Image_VerticalSize" />
      <Column Name="4425-System_ImageParsingName" />
      <Column Name="4426-System_Importance" />
      <Column Name="4427-System_ImportanceText" />
      <Column Name="4428-System_InvalidPathValue" />
      <Column Name="4429-System_IsAttachment" Value="False" />
      <Column Name="4430-System_IsDeleted" />
      <Column Name="4431-System_IsEncrypted" Value="False" />
      <Column Name="4432-System_IsFlagged" />
      <Column Name="4433-System_IsFlaggedComplete" />
      <Column Name="4434-System_IsFolder" Value="True" />
      <Column Name="4435-System_IsIncomplete" />
      <Column Name="4436-System_IsRead" />
      <Column Name="4437-System_ItemAuthors" />
      <Column Name="4438-System_ItemDate" Value="AOUpjdlc1gE=" />
      <Column Name="4440-System_ItemFolderPathDisplay" Value="C:\ProgramData\Microsoft\Windows" />
      <Column Name="4441-System_ItemFolderPathDisplayNarrow" Value="Windows (C:\ProgramData\Microsoft)" />
      <Column Name="4442-System_ItemName" Value="Start Menu" />
      <Column Name="4443-System_ItemNameDisplay" Value="Start Menu" />
      <Column Name="4444-System_ItemNameDisplayWithoutExtension" Value="Start Menu" />
      <Column Name="4445-System_ItemNamePrefix" />
      <Column Name="4446-System_ItemParticipants" />
      <Column Name="4447-System_ItemPathDisplay" Value="C:\ProgramData\Microsoft\Windows\Start Menu" />
      <Column Name="4448-System_ItemPathDisplayNarrow" Value="Start Menu (C:\ProgramData\Microsoft\Windows)" />
      <Column Name="4449-System_ItemSubType" />
      <Column Name="4450-System_ItemType" Value="Directory" />
      <Column Name="4453-System_Journal_Contacts" />
      <Column Name="4454-System_Journal_EntryType" />
      <Column Name="4455-System_Keywords" />
      <Column Name="4456-System_Kind" Value="ZgBvAGwAZABlAHIA" />
      <Column Name="4457-System_KindText" Value="Folder" />
      <Column Name="4458-System_Language" />
      <Column Name="4459-System_LastSyncError" />
      <Column Name="4460-System_LastSyncWarning" />
      <Column Name="4461-System_Link_Arguments" />
      <Column Name="4462-System_Link_DateVisited" />
      <Column Name="4463-System_Link_FeedItemLocalId" />
      <Column Name="4465-System_Link_TargetParsingPath" />
      <Column Name="4466-System_Link_TargetSFGAOFlags" />
      <Column Name="4468-System_Link_TargetUrl" />
      <Column Name="4469-System_Link_TargetUrlHostName" />
      <Column Name="4470-System_Link_TargetUrlPath" />
      <Column Name="4471-System_LowKeywords" />
      <Column Name="4472-System_MIMEType" />
      <Column Name="4473-System_Media_AverageLevel" />
      <Column Name="4474-System_Media_ClassPrimaryID" />
      <Column Name="4475-System_Media_ClassSecondaryID" />
      <Column Name="4476-System_Media_CollectionGroupID" />
      <Column Name="4477-System_Media_CollectionID" />
      <Column Name="4478-System_Media_ContentDistributor" />
      <Column Name="4479-System_Media_ContentID" />
      <Column Name="4480-System_Media_CreatorApplication" />
      <Column Name="4481-System_Media_CreatorApplicationVersion" />
      <Column Name="4482-System_Media_DVDID" />
      <Column Name="4483-System_Media_DateEncoded" />
      <Column Name="4484-System_Media_DateReleased" />
      <Column Name="4485-System_Media_DlnaProfileID" />
      <Column Name="4486-System_Media_Duration" />
      <Column Name="4487-System_Media_EncodedBy" />
      <Column Name="4488-System_Media_EpisodeNumber" />
      <Column Name="4489-System_Media_FrameCount" />
      <Column Name="4490-System_Media_MCDI" />
      <Column Name="4491-System_Media_MetadataContentProvider" />
      <Column Name="4492-System_Media_Producer" />
      <Column Name="4493-System_Media_ProtectionType" />
      <Column Name="4494-System_Media_ProviderRating" />
      <Column Name="4495-System_Media_ProviderStyle" />
      <Column Name="4496-System_Media_Publisher" />
      <Column Name="4497-System_Media_SeasonNumber" />
      <Column Name="4498-System_Media_SeriesName" />
      <Column Name="4499-System_Media_SubTitle" />
      <Column Name="4500-System_Media_SubscriptionContentId" />
      <Column Name="4501-System_Media_ThumbnailLargePath" />
      <Column Name="4502-System_Media_ThumbnailLargeUri" />
      <Column Name="4503-System_Media_ThumbnailSmallPath" />
      <Column Name="4504-System_Media_ThumbnailSmallUri" />
      <Column Name="4505-System_Media_UniqueFileIdentifier" />
      <Column Name="4506-System_Media_UserNoAutoInfo" />
      <Column Name="4507-System_Media_UserWebUrl" />
      <Column Name="4508-System_Media_Writer" />
      <Column Name="4509-System_Media_Year" />
      <Column Name="4510-System_MediumKeywords" />
      <Column Name="4512-System_Message_AttachmentNames" />
      <Column Name="4513-System_Message_BccAddress" />
      <Column Name="4514-System_Message_BccName" />
      <Column Name="4515-System_Message_CcAddress" />
      <Column Name="4516-System_Message_CcName" />
      <Column Name="4517-System_Message_ConversationID" />
      <Column Name="4518-System_Message_ConversationIndex" />
      <Column Name="4519-System_Message_DateReceived" />
      <Column Name="4520-System_Message_DateSent" />
      <Column Name="4521-System_Message_Flags" />
      <Column Name="4522-System_Message_FromAddress" />
      <Column Name="4523-System_Message_FromName" />
      <Column Name="4524-System_Message_HasAttachments" />
      <Column Name="4525-System_Message_IsFwdOrReply" />
      <Column Name="4526-System_Message_MessageClass" />
      <Column Name="4527-System_Message_Participants" />
      <Column Name="4528-System_Message_ProofInProgress" />
      <Column Name="4529-System_Message_SenderAddress" />
      <Column Name="4530-System_Message_SenderName" />
      <Column Name="4531-System_Message_Store" />
      <Column Name="4532-System_Message_ToAddress" />
      <Column Name="4533-System_Message_ToDoFlags" />
      <Column Name="4534-System_Message_ToDoTitle" />
      <Column Name="4535-System_Message_ToName" />
      <Column Name="4536-System_MileageInformation" />
      <Column Name="4537-System_Music_AlbumArtist" />
      <Column Name="4538-System_Music_AlbumArtistSortOverride" />
      <Column Name="4539-System_Music_AlbumID" />
      <Column Name="4540-System_Music_AlbumTitle" />
      <Column Name="4541-System_Music_AlbumTitleSortOverride" />
      <Column Name="4542-System_Music_Artist" />
      <Column Name="4543-System_Music_ArtistSortOverride" />
      <Column Name="4544-System_Music_BeatsPerMinute" />
      <Column Name="4545-System_Music_Composer" />
      <Column Name="4546-System_Music_ComposerSortOverride" />
      <Column Name="4547-System_Music_Conductor" />
      <Column Name="4548-System_Music_ContentGroupDescription" />
      <Column Name="4549-System_Music_DiscNumber" />
      <Column Name="4550-System_Music_DisplayArtist" />
      <Column Name="4551-System_Music_Genre" />
      <Column Name="4552-System_Music_InitialKey" />
      <Column Name="4553-System_Music_IsCompilation" />
      <Column Name="4555-System_Music_Mood" />
      <Column Name="4556-System_Music_PartOfSet" />
      <Column Name="4557-System_Music_Period" />
      <Column Name="4558-System_Music_TrackNumber" />
      <Column Name="4559-System_NotUserContent" />
      <Column Name="4560-System_Note_Color" />
      <Column Name="4561-System_Note_ColorText" />
      <Column Name="4562-System_OriginalFileName" />
      <Column Name="4563-System_ParentalRating" />
      <Column Name="4564-System_ParentalRatingReason" />
      <Column Name="4565-System_ParsingName" Value="Start Menu" />
      <Column Name="4566-System_Photo_Aperture" />
      <Column Name="4567-System_Photo_CameraManufacturer" />
      <Column Name="4568-System_Photo_CameraModel" />
      <Column Name="4569-System_Photo_ContrastText" />
      <Column Name="4570-System_Photo_DateTaken" />
      <Column Name="4571-System_Photo_DigitalZoom" />
      <Column Name="4572-System_Photo_Event" />
      <Column Name="4573-System_Photo_ExposureBias" />
      <Column Name="4574-System_Photo_ExposureProgram" />
      <Column Name="4575-System_Photo_ExposureProgramText" />
      <Column Name="4576-System_Photo_ExposureTime" />
      <Column Name="4577-System_Photo_FNumber" />
      <Column Name="4578-System_Photo_Flash" />
      <Column Name="4579-System_Photo_FlashFired" />
      <Column Name="4580-System_Photo_FlashText" />
      <Column Name="4581-System_Photo_FocalLength" />
      <Column Name="4582-System_Photo_FocalLengthInFilm" />
      <Column Name="4583-System_Photo_GainControlText" />
      <Column Name="4584-System_Photo_ISOSpeed" />
      <Column Name="4585-System_Photo_LightSource" />
      <Column Name="4586-System_Photo_MaxAperture" />
      <Column Name="4587-System_Photo_MeteringMode" />
      <Column Name="4588-System_Photo_MeteringModeText" />
      <Column Name="4589-System_Photo_Orientation" />
      <Column Name="4590-System_Photo_OrientationText" />
      <Column Name="4591-System_Photo_PeopleNames" />
      <Column Name="4592-System_Photo_PhotometricInterpretationText" />
      <Column Name="4593-System_Photo_ProgramModeText" />
      <Column Name="4594-System_Photo_SaturationText" />
      <Column Name="4595-System_Photo_SharpnessText" />
      <Column Name="4596-System_Photo_ShutterSpeed" />
      <Column Name="4597-System_Photo_SubjectDistance" />
      <Column Name="4598-System_Photo_TagViewAggregate" />
      <Column Name="4599-System_Photo_WhiteBalance" />
      <Column Name="45-System_Search_QueryPropertyHits" />
      <Column Name="4600-System_Photo_WhiteBalanceText" />
      <Column Name="4601-System_Priority" />
      <Column Name="4602-System_PriorityText" />
      <Column Name="4603-System_Project" />
      <Column Name="4604-System_ProviderItemID" />
      <Column Name="4605-System_Rating" />
      <Column Name="4606-System_RatingText" />
      <Column Name="4607-System_RecordedTV_ChannelNumber" />
      <Column Name="4608-System_RecordedTV_DateContentExpires" />
      <Column Name="4609-System_RecordedTV_EpisodeName" />
      <Column Name="4610-System_RecordedTV_IsATSCContent" />
      <Column Name="4611-System_RecordedTV_IsClosedCaptioningAvailable" />
      <Column Name="4612-System_RecordedTV_IsDTVContent" />
      <Column Name="4613-System_RecordedTV_IsHDContent" />
      <Column Name="4614-System_RecordedTV_IsRepeatBroadcast" />
      <Column Name="4615-System_RecordedTV_IsSAP" />
      <Column Name="4616-System_RecordedTV_NetworkAffiliation" />
      <Column Name="4617-System_RecordedTV_OriginalBroadcastDate" />
      <Column Name="4618-System_RecordedTV_ProgramDescription" />
      <Column Name="4619-System_RecordedTV_RecordingTime" />
      <Column Name="4620-System_RecordedTV_StationCallSign" />
      <Column Name="4621-System_RecordedTV_StationName" />
      <Column Name="4622-System_SDID" />
      <Column Name="4623-System_SFGAOFlags" Value="1887437183" />
      <Column Name="4624-System_Search_AccessCount" Value="0" />
      <Column Name="4625-System_Search_AutoSummary" />
      <Column Name="4631F-System_Search_GatherTime" Value="GM0w1BRh1gE=" />
      <Column Name="4633-System_Search_LastIndexedTotalTime" Value="0,015625" />
      <Column Name="4637-System_Search_Store" Value="file" />
      <Column Name="4638-System_Security_EncryptionOwners" />
      <Column Name="4639-System_Security_EncryptionOwnersDisplay" />
      <Column Name="4640-System_Sensitivity" />
      <Column Name="4641-System_SensitivityText" />
      <Column Name="4642-System_Setting_Condition" />
      <Column Name="4643-System_Setting_GroupID" />
      <Column Name="4644-System_Setting_HostID" />
      <Column Name="4645-System_Setting_PageID" />
      <Column Name="4646-System_Setting_SettingID" />
      <Column Name="4647-System_Setting_SettingsEnvironmentID" />
      <Column Name="4648-System_Shell_OmitFromView" />
      <Column Name="4651-System_Software_AppId" />
      <Column Name="4652-System_Software_DateLastUsed" />
      <Column Name="4654-System_Software_ProductVersion" />
      <Column Name="4655-System_Software_TimesUsed" />
      <Column Name="4656-System_SoftwareUsed" />
      <Column Name="4657-System_SourceItem" />
      <Column Name="4658-System_StartDate" />
      <Column Name="4659-System_Status" />
      <Column Name="4660-System_StorageProviderError" />
      <Column Name="4661-System_StorageProviderFileIdentifier" />
      <Column Name="4662-System_StorageProviderFileVersion" />
      <Column Name="4663-System_StorageProviderFullyQualifiedId" />
      <Column Name="4664-System_StorageProviderId" />
      <Column Name="4665-System_StorageProviderShareStatuses" />
      <Column Name="4666-System_StorageProviderStatus" />
      <Column Name="4667-System_Subject" />
      <Column Name="4668-System_Supplemental_Album" />
      <Column Name="4669-System_Supplemental_AlbumID" />
      <Column Name="4670-System_Supplemental_Location" />
      <Column Name="4671-System_Supplemental_Person" />
      <Column Name="4672-System_Supplemental_ResourceId" />
      <Column Name="4673-System_Supplemental_Tag" />
      <Column Name="4674-System_SyncTransferStatus" />
      <Column Name="4675-System_SyncTransferStatusFlags" />
      <Column Name="4677-System_Task_CompletionStatus" />
      <Column Name="4678-System_Task_Owner" />
      <Column Name="4679-System_ThumbnailCacheId" Value="ipTS/7SbMS8=" />
      <Column Name="4680-System_Tile_Background" />
      <Column Name="4681-System_Tile_EncodedTargetPath" />
      <Column Name="4682-System_Tile_SmallLogoPath" />
      <Column Name="4683-System_Title" />
      <Column Name="4684-System_TitleSortOverride" />
      <Column Name="4685-System_TransferOrder" />
      <Column Name="4686-System_TransferPosition" />
      <Column Name="4687-System_TransferSize" />
      <Column Name="4688-System_Video_Compression" />
      <Column Name="4689-System_Video_Director" />
      <Column Name="4690-System_Video_EncodingBitrate" />
      <Column Name="4691-System_Video_FourCC" />
      <Column Name="4692-System_Video_FrameHeight" />
      <Column Name="4693-System_Video_FrameRate" />
      <Column Name="4694-System_Video_FrameWidth" />
      <Column Name="4695-System_Video_HorizontalAspectRatio" />
      <Column Name="4696-System_Video_IsSpherical" />
      <Column Name="4697-System_Video_IsStereo" />
      <Column Name="4698-System_Video_Orientation" />
      <Column Name="4699-System_Video_SampleSize" />
      <Column Name="46-System_Search_Completion" />
      <Column Name="4700-System_Video_StreamName" />
      <Column Name="4701-System_Video_TotalBitrate" />
      <Column Name="4702-System_Video_VerticalAspectRatio" />
      <Column Name="4703-System_VolumeId" />
      <Column Name="4704-Corel_Document_CmykProfile" />
      <Column Name="4705-Corel_Document_ColorMode" />
      <Column Name="4706-Corel_Document_FontList" />
      <Column Name="4707-Corel_Document_GrayscaleProfile" />
      <Column Name="4708-Corel_Document_Languages" />
      <Column Name="4709-Corel_Document_LayerNames" />
      <Column Name="4710-Corel_Document_ObjectNames" />
      <Column Name="4711-Corel_Document_PageNames" />
      <Column Name="4712-Corel_Document_PageOrientation" />
      <Column Name="4713-Corel_Document_PageSizeName" />
      <Column Name="4714-Corel_Document_RenderingIntent" />
      <Column Name="4715-Corel_Document_RgbProfile" />
      <Column Name="4716-Corel_Document_SpotColors" />
      <Column Name="4717-Corel_ImageFile_ColorMode" />
      <Column Name="4718-Corel_ImageFile_ColorProfile" />
      <Column Name="4723-Tracker_PDF_Creator" />
      <Column Name="4724-Tracker_PDF_Producer" />
      <Column Name="4725-Tracker_PDF_SpecVersion" />
      <Column Name="4726-System_Null" />
      <Column Name="5-System_ItemTypeText" Value="File folder" />
      <Column Name="WorkID" Value="1" />
    </Row>
```
The (**SystemIndex_Gthr**) table's columns:<br>

```    <Row>
      <Column Name="AppOwnerId"/>
      <Column Name="CalculatedPropertyFlags" Value="4864"/>
      <Column Name="ClientID"/>
      <Column Name="CrawlNumberCrawled" Value="88"/>
      <Column Name="DeletedCount"/>
      <Column Name="DocumentID" Value="1"/>
      <Column Name="FailureUpdateAttempts"/>
      <Column Name="FileName" Value="Start Menu"/>
      <Column Name="LastModified" Value="AdZhFAbxSx8="/>
      <Column Name="LastRequestedRunTime"/>
      <Column Name="Priority"/>
      <Column Name="RequiredSIDs"/>
      <Column Name="RunTime"/>
      <Column Name="ScopeID" Value="8"/>
      <Column Name="SDID" Value="1"/>
      <Column Name="StartAddressIdentifier" Value="0"/>
      <Column Name="StorageProviderId"/>
      <Column Name="TransactionExtendedFlags"/>
      <Column Name="TransactionFlags" Value="-2143286922"/>
      <Column Name="UserData"/>
    </Row>
```    
  The (**SystemIndex_GthrPth**) table's columns:<br>
  
```    <Row>
      <Column Name="Name" Value="C:"/>
      <Column Name="Parent" Value="2"/>
      <Column Name="Scope" Value="3"/>
    </Row>
```    
 
