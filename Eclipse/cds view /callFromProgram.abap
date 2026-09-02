" ---------------IN SE38------------START--------------------------------

REPORT ZCALLCDSASSOCIATION.

data: wa_vbeln type vbeln_va.
SELECT-OPTIONS : s_vbeln for wa_vbeln.
SELECT *
  FROM zcds_vbap_association " put here your view
  WHERE vbeln in @s_vbeln
  INTO TABLE @DATA(it_result).

cl_demo_output=>display( it_result ).

" ---------------IN SE38----------END----------------------------------

" ---------------IN Eclipse CDS view---------------- START-------------
  
@AbapCatalog.sqlViewName: 'zcds_vbap_ass'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'item details'
@Metadata.ignorePropagatedAnnotations: true
define view zcds_vbap_association 
  as select from vbak

  association [0..*] to vbap as _Item
    on $projection.vbeln = _Item.vbeln

{
    key vbeln,
        erdat,
        erzet,
        ernam,

        _Item.posnr,
        _Item.matnr
//        _Item
} 

" ---------------IN Eclipse CDS view---------------- END---------------
