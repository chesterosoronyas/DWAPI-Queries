#Lab extracts for C&T
select ''                                                                               AS SatelliteName,
       0                                                                                AS FacilityId,
       d.unique_patient_no                                                              as PatientID,
       d.patient_id                                                                     as PatientPK,
       l.encounter_id                                                                   as VisitId,
       coalesce(DATE(l.date_test_requested), DATE(l.visit_date))                        as OrderedByDate,
       DATE(l.date_test_result_received)                                                as ReportedByDate,
       i.siteCode                                                                       as SiteCode,
       i.facilityName                                                                   as FacilityName,
       (case lab_test
            when 5497 then "CD4 Count"
            when 730 then "CD4 Percent"
            when 654 then "ALT"
            when 790 then "Serum creatinine (umol/L)"
            when 856 then "HIV Viral Load"
            when 1305 then "HIV Viral Load"
            when 21 then "Hemoglobin (HGB)"
            when 1029 then "VDRL Titre"
            when 1031 then "Treponema Pallidum Hemagglutination Assay"
            when 1619 then "Rapid Plasma Reagin"
            when 1032 then "Treponema Pallidum Hemagglutination Assay, Qualitative"
            else "" end)                                                                as TestName,
       date(l.visit_date)                                                               as DateSampleTaken,
       (case l.order_reason
            when 843 then 'Confirmation of treatment failure (repeat VL)'
            when 1434 then 'Pregnancy'
            when 162080 then 'Baseline VL (for infants diagnosed through EID)'
            when 1259 then 'Single Drug Substitution'
            when 159882 then 'Breastfeeding'
            when 163523 then 'Clinical failure'
            when 161236 then 'Routine'
            when 160032 then 'Confirmation of persistent low level Viremia (PLLV)' end) as Reason,
       if(lab_test = 299, (case test_result
                               when 1228 then "REACTIVE"
                               when 1229 then "NON-REACTIVE"
                               when 1304 then "POOR SAMPLE QUALITY" end),
          if(lab_test = 1030, (case test_result
                                   when 1138 then "INDETERMINATE"
                                   when 664 then "NEGATIVE"
                                   when 703 then "POSITIVE"
                                   when 1304 then "POOR SAMPLE QUALITY" end),
             if(lab_test = 302, (case test_result
                                     when 1115 then "Normal"
                                     when 1116 then "Abnormal"
                                     when 1067 then "Unknown" end),
                if(lab_test = 32, (case test_result
                                       when 664 then "NEGATIVE"
                                       when 703 then "POSITIVE"
                                       when 1138 then "INDETERMINATE" end),
                   if(lab_test = 1305, (case test_result
                                            when 1306 then "BEYOND DETECTABLE LIMIT"
                                            when 1301 then "DETECTED"
                                            when 1302 then "LDL"
                                            when 1304 then "POOR SAMPLE QUALITY" end),
                      if(lab_test = 1029,
                         (case test_result when 664 then "Negative" when 703 then "Positive" end),
                         if(lab_test = 1031, (case test_result
                                                  when 1311 then "<1:2"
                                                  when 1312 then "01:02"
                                                  when 1313 then "1:4"
                                                  when 1314 then "01:08"
                                                  when 1315 then "01:16"
                                                  when 1316 then "01:32"
                                                  when 1317 then ">1:32"
                                                  when 1304 then "Poor Sample Quality"
                                                  when 163621 then "1:64"
                                                  when 163622 then "1:128"
                                                  when 163623 then "1:256"
                                                  when 163624 then ">1:572" end),
                            if(lab_test = 1032, (case test_result
                                                     when 703 then "Positive"
                                                     when 664 then "Negative"
                                                     when 1300 then "Equivocal"
                                                     when 1304 then "Poor Sample Quality" end),
                               if(lab_test = 1619, (case test_result
                                                        when 703 then "Positive"
                                                        when 664 then "Negative"
                                                        when 1067 then "Unknown" end),
                                  test_result)))))))))                                  as TestResult,
       NULL                                                                             as EnrollmentTest,
       o.sample_type                                                                    as SampleType,
       'KenyaEMR'                                                                       as Emr,
       'Kenya HMIS II'                                                                  as Project,
       l.date_created                                                                   as Date_Created,
       l.date_last_modified                                                             as Date_Last_Modified
from kenyaemr_etl.etl_laboratory_extract l
         left join openmrs.kenyaemr_order_entry_lab_manifest_order o on l.order_id = o.order_id
         join kenyaemr_etl.etl_patient_demographics d on d.patient_id = l.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where d.unique_patient_no is not null;