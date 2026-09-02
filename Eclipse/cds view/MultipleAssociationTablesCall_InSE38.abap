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
  as select from vbap

  association [1..1] to vbak as _Header
    on $projection.vbeln = _Header.vbeln

  association [0..1] to makt as _Material
    on  $projection.matnr = _Material.matnr
//    and _Material.spras = $session.system_language

{
    key vbeln,
    key posnr,
        matnr,
        arktx,

        _Header.erdat,
        _Header.erzet,
        _Header.ernam,

        _Material.maktx
}


" ---------------IN Eclipse CDS view---------------- END---------------
