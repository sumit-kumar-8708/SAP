@AbapCatalog.sqlViewName: 'ZCDSASSV2'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'testing'
@Metadata.ignorePropagatedAnnotations: true

define view ZCDS_ASSOCIATION
  as select from zhrempmaster

  association to zhrempdet as _cds_association
    on $projection.id = _cds_association.emp_id

{
    key emp_id     as id,
        emp_name   as name,
        emp_add    as addr,
        emp_mobile as mobile,

        _cds_association
}
