/************************************************************************
Name: IMP_DescuentosManager
Copyright © 2023 Salesforce
========================================================================
Purpose:
Servicio web para la consulta de descuentos desde SAP 
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
3.0      rotrejo@ts4.mx     09/05/2023     
************************************************************************/
public inherited sharing class IMP_DescuentosManager {

    public List<T_A000> T_A305;
    public List<T_A000> T_A940;
    public List<T_A000> T_A993;
    public List<T_A000> T_A996;
    public List<T_A000> T_A997;
    public List<T_A000> T_A999;
    
    public class T_A000{
        public String KSCHL;//Clase de Condición
        public String VKORG;//Organizacion de Ventas
        public String VTWEG;//Canal de Ventas
        public String KUNNR;//Numero del cliente
        public String MATNR;//Número del material
        public String KBETR;//Importe/Porcentaje
        public String KONWA;//Unidad de condición (Moneda o porcentaje)
        public String DATAB;//Fecha Inicial
        public String DATBI;//Fecha Final
        public String VKBUR;//Oficina de Ventas
        public String CHARG;//Lote
        public String PLTYP;//Lista de Precios
        public String KDGRP;//Grupo de Clientes
        public String MATKL;//Grupo de Articulos
        public String KONDM;//Grupo de Materiales      
        public String AUART_SD;//Clase de Documento de Ventas
        public String KNUMH;
        
    }

    
    /*******************************************************************
    Purpose: Actualiza el listado de descuento.
    Parameters:
    Returns: 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static void upsertDiscounts(){
        IMP_DescuentosManager newDiscount = new IMP_DescuentosManager();
        List<IMP_DescuentosManager.T_A000> listDiscount = new  List<IMP_DescuentosManager.T_A000>();
        IMP_DescuentosManager.T_A000 itemDiscount = new IMP_DescuentosManager.T_A000();
        listDiscount.add(itemDiscount);
        newDiscount.T_A305 = listDiscount;
        newDiscount.T_A940 = listDiscount;
        newDiscount.T_A993 = listDiscount;
        newDiscount.T_A996 = listDiscount;
        newDiscount.T_A997 = listDiscount;
        newDiscount.T_A999 = listDiscount;
        String body = JSON.serialize(newDiscount);
        HttpResponse response = IMP_CalloutUtils.getResponse(body,IMP_ServiceConstants.DESCUENTOS_API_URL);
        List<Descuento__c> listDescuento = new List<Descuento__c>();
        Set<String> setId = new  Set<String>();
        System.debug('Body '+response.getBody());
        IMP_DescuentosManager discountResponse = (IMP_DescuentosManager)JSON.deserialize(response.getBody(),IMP_DescuentosManager.class); 
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A305){
            listDescuento.add(getDescuento('A305',descuento));
            setId.add(descuento.KNUMH);
        }
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A999){
            listDescuento.add(getDescuento('A999',descuento));
            setId.add(descuento.KNUMH);
        }
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A993){
            listDescuento.add(getDescuento('A993',descuento));
            setId.add(descuento.KNUMH);
        }
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A996){
            listDescuento.add(getDescuento('A996',descuento));
            setId.add(descuento.KNUMH);
        }
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A997){
            listDescuento.add(getDescuento('A997',descuento));
            setId.add(descuento.KNUMH);
        }
        for(IMP_DescuentosManager.T_A000 descuento: discountResponse.T_A940){
            listDescuento.add( getDescuento('A940',descuento));
            setId.add(descuento.KNUMH);
        } 
        System.debug('LISTA DE DESC');
        System.debug(listDescuento.size());
        List<Descuento__c> listDesc = [SELECT Id,IMP_IdExterno__c,IMP_SecuenciaAcceso__c,IMP_FechaFinal__c,Name FROM Descuento__c WHERE IMP_IdExterno__c NOT IN : setId];
        for(Descuento__c descDesco: listDesc){
            System.debug(descDesco.IMP_SecuenciaAcceso__c+'-'+descDesco.IMP_IdExterno__c);
            descDesco.IMP_FechaFinal__c = date.today()-1;
            
        }
        System.debug(listDescuento);
        Database.executeBatch(new IMP_BatchDescuentos(listDesc),1000);  
        Database.executeBatch(new BatchUpsertDiscounts(listDescuento),1000);  
        

        /*List<Database.SaveResult> resultUpdate = Database.update(listDesc, FALSE);
        for(Database.SaveResult itemResult :resultUpdate ){
            if(!itemResult.isSuccess()){
                system.debug(itemResult.getErrors());
            }
        }
        List<Database.UpsertResult> results = Database.upsert(listDescuento,Descuento__c.IMP_IdExterno__c , FALSE);
        for(Database.UpsertResult itemResult : results){
            if(!itemResult.isSuccess()){
                system.debug(itemResult.getErrors());
            }
        }*/
    }
    
    
    /*******************************************************************
    Purpose: Obtiene el descuento por cotización
    Parameters:Quote
    Returns:WrapperSecuences 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static WrapperSecuences getDiscountByQuote(Quote quote){
        WrapperSecuences wrapperReturn = new WrapperSecuences();
        Map<String,Descuento__c> mapSecuenceA305 = new  Map<String,Descuento__c>();
        Map<String,Descuento__c> mapSecuenceA999 = new  Map<String,Descuento__c>();
        Map<String,List<Descuento__c>> mapSecuenceA999Aux = new  Map<String,List<Descuento__c>>();
        Map<String,Descuento__c> mapSecuenceA993 = new  Map<String,Descuento__c>();
        Map<String,Descuento__c> mapSecuenceA996 = new  Map<String,Descuento__c>();
        Map<String,Descuento__c> mapSecuenceA997 = new  Map<String,Descuento__c>();
        Map<String,Descuento__c> mapSecuence9A40 = new  Map<String,Descuento__c>();

        for(Descuento__c disc : [SELECT Id, IMP_ClaseCondicion__c, IMP_OrganizacionVentas__c, IMP_CanalVentas__c, IMP_NumeroCliente__c,
                                      IMP_NumeroMaterial__c, IMP_ImportePorcentaje__c, IMP_UnidadCondicion__c, IMP_FechaInicial__c, 
                                      IMP_FechaFinal__c, IMP_OficinaVentas__c, IMP_Lote__c, IMP_ListaPrecios__c, IMP_GrupoClientes__c,
                                      IMP_GrupoArticulos__c, IMP_GrupoMateriales__c, IMP_ClaseDocumentoVentas__c, IMP_SecuenciaAcceso__c,
                                      IMP_Valido__c FROM Descuento__c  WHERE IMP_Valido__c = true  AND 
                                      ((IMP_OrganizacionVentas__c=:quote.Account.OrganizacionVentas__c AND IMP_CanalVentas__c=:quote.Account.clave_delcanal__c AND IMP_NumeroCliente__c=:quote.Account.id_de_sap__c)
                                      OR (IMP_OrganizacionVentas__c=:quote.Account.OrganizacionVentas__c AND IMP_OficinaVentas__c=:quote.Pricebook2.Sucursal__c AND IMP_ListaPrecios__c =: quote.Pricebook2.Lista_de_precios_SAP__c)
                                      OR IMP_GrupoClientes__c=:quote.Account.grupo__c
                                      OR (IMP_OrganizacionVentas__c=:quote.Account.OrganizacionVentas__c AND  IMP_OficinaVentas__c=:quote.Pricebook2.Sucursal__c AND IMP_GrupoClientes__c=:quote.Account.grupo__c )
                                      OR IMP_ClaseDocumentoVentas__c='TA')
                                      ORDER BY IMP_FechaInicial__c ASC]){
                                          if(disc.IMP_SecuenciaAcceso__c=='A305'){
                                              mapSecuenceA305.put(disc.IMP_OrganizacionVentas__c+'-'+disc.IMP_CanalVentas__c+'-'+disc.IMP_NumeroCliente__c+'-'+disc.IMP_NumeroMaterial__c, disc);
                                          }
                                          if(disc.IMP_SecuenciaAcceso__c=='A999'){
                                             // mapSecuenceA999.put(disc.IMP_OrganizacionVentas__c+'-'+disc.IMP_OficinaVentas__c+'-'+disc.IMP_ListaPrecios__c+'-'+disc.IMP_NumeroMaterial__c+'-'+disc.IMP_Lote__c, disc);
                                              if(!mapSecuenceA999Aux.containsKey(disc.IMP_NumeroMaterial__c)){
                                                  mapSecuenceA999Aux.put(disc.IMP_NumeroMaterial__c, new List<Descuento__c>());
                                              }
                                              mapSecuenceA999Aux.get(disc.IMP_NumeroMaterial__c).add(disc);
                                          }
                                          if(disc.IMP_SecuenciaAcceso__c=='A993'){
                                              mapSecuenceA993.put(disc.IMP_GrupoClientes__c+'-'+disc.IMP_GrupoArticulos__c, disc);
                                          }
                                          if(disc.IMP_SecuenciaAcceso__c=='A996'){
                                              mapSecuenceA996.put(disc.IMP_OrganizacionVentas__c+'-'+disc.IMP_OficinaVentas__c+'-'+disc.IMP_ListaPrecios__c+'-'+disc.IMP_NumeroMaterial__c, disc);
                                          }
                                          if(disc.IMP_SecuenciaAcceso__c=='A997'){
                                              mapSecuenceA997.put(disc.IMP_OrganizacionVentas__c+'-'+disc.IMP_OficinaVentas__c+'-'+disc.IMP_GrupoClientes__c+'-'+disc.IMP_GrupoMateriales__c, disc);
                                          }
                                          if(disc.IMP_SecuenciaAcceso__c=='A940'){
                                              mapSecuence9A40.put(disc.IMP_ClaseDocumentoVentas__c, disc);
                                          }
                                   
                                      }
        for(String key : mapSecuenceA999Aux.keySet()){
            System.debug('--------------------');
            List<String> listLotes = new  List<String>();
            System.debug('Número del Material '+ key);
            System.debug( mapSecuenceA999Aux.get(key));
            Map<String,Descuento__c> mapDescLote = new Map<String,Descuento__c>();
            for(Descuento__c disc : mapSecuenceA999Aux.get(key)){
                listLotes.add(disc.IMP_Lote__c);
                mapDescLote.put(disc.IMP_Lote__c,disc);
            }
            listLotes.sort();
            String lote = listLotes.size()>=1 ? listLotes.get(0): '';
            System.debug('LOTE CORRECTO ::'+ lote);  
            mapSecuenceA999.put(mapSecuenceA999Aux.get(key).get(0).IMP_OrganizacionVentas__c+'-'+mapSecuenceA999Aux.get(key).get(0).IMP_OficinaVentas__c+'-'+mapSecuenceA999Aux.get(key).get(0).IMP_ListaPrecios__c+'-'+key, mapDescLote.get(lote));
        }
        
        for(String key : mapSecuenceA305.keySet()){
            System.debug('Llave -> A305 ('+ key+')');
            System.debug(mapSecuenceA305.get(key));
        }
        
        for(String key : mapSecuenceA999.keySet()){
            System.debug('Llave -> A999 ('+ key+')');
            System.debug(mapSecuenceA999.get(key));
        }
        System.debug('-------------------------');
        for(String key : mapSecuenceA993.keySet()){
            System.debug('Llave -> A993 ('+ key+')');
            System.debug(mapSecuenceA993.get(key));
        }
        System.debug('-------------------------');
        for(String key : mapSecuenceA996.keySet()){
            System.debug('Llave -> A996 ('+ key+')');
            System.debug(mapSecuenceA996.get(key));
        }
        System.debug('-------------------------');
        for(String key : mapSecuenceA997.keySet()){
            System.debug('Llave -> A997 ('+ key+')');
            System.debug(mapSecuenceA997.get(key));
        }
        System.debug('-------------------------');
        for(String key : mapSecuence9A40.keySet()){
            System.debug('Llave -> A940 ('+ key+')');
            System.debug(mapSecuence9A40.get(key));
        }

        wrapperReturn.mapSecuenceA305=mapSecuenceA305;
        wrapperReturn.mapSecuenceA999=mapSecuenceA999;
        wrapperReturn.mapSecuenceA993=mapSecuenceA993;
        wrapperReturn.mapSecuenceA996=mapSecuenceA996;
        wrapperReturn.mapSecuenceA997=mapSecuenceA997;
        wrapperReturn.mapSecuence9A40=mapSecuence9A40;
        return wrapperReturn;
    }

    /*******************************************************************
    Purpose: Obtiene el que aplica
    Parameters: WrapperSecuencesParam Param, WrapperSecuences DiscountsBySecuence
    Returns: Descuento__c 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Descuento__c getDiscountByToApply(WrapperSecuencesParam Param, WrapperSecuences DiscountsBySecuence){
       
        Descuento__c descuentoPromo = new Descuento__c();
        String sKeyA305 = Param.OrgVentas +'-'+ Param.canalVentas +'-'+ Param.numeroCliente +'-'+ Param.numeroMaterial; //Ok, si aplica número de material
        String sKeyA999 = Param.OrgVentas + '-'+ Param.OficinaVentas +'-'+ Param.ListaPrecios +'-'+ Param.numeroMaterial; //Ok, si aplica número de material, aplica el lote, no se ha ubicado el campo en SF?
        String sKeyA993 = Param.GrupoClientes +'-'+ Param.GrupoArticulos; // Gr.client.-Gpo.artíc va sin material
        String sKeyA996 = Param.OrgVentas +'-'+ Param.OficinaVentas +'-'+ Param.ListaPrecios + '-'+Param.numeroMaterial; //OK
        String sKeyA997 = Param.OrgVentas +'-'+ Param.OficinaVentas +'-'+ Param.GrupoClientes + '-'+ Param.GrupoMateriales; //En lugar de numeroMaterial es GrupoMateriales
        String sKey9A40 = Param.ClaseDoc;        
        System.debug('Secuencia sKeyA305: ' + sKeyA305);
        System.debug('Secuencia sKeyA999: ' + sKeyA999);
        System.debug('Secuencia sKeyA993: ' + sKeyA993);
        System.debug('Secuencia sKeyA996: ' + sKeyA996);
        System.debug('Secuencia sKeyA997: ' + sKeyA997);
        System.debug('Secuencia sKey9A40: ' + sKey9A40);
        if(DiscountsBySecuence.mapSecuenceA305.containsKey(sKeyA305) ){ 
            descuentoPromo = DiscountsBySecuence.mapSecuenceA305.get(sKeyA305);
            System.debug('Secuencia encontrada sKeyA305: ' + sKeyA305);
        }
        else if(DiscountsBySecuence.mapSecuenceA999.containsKey(sKeyA999)){
            descuentoPromo = DiscountsBySecuence.mapSecuenceA999.get(sKeyA999);
        }
        else if(DiscountsBySecuence.mapSecuenceA993.containsKey(sKeyA993)){
            descuentoPromo = DiscountsBySecuence.mapSecuenceA993.get(sKeyA993);
        }
        else if(DiscountsBySecuence.mapSecuenceA996.containsKey(sKeyA996)){
            descuentoPromo = DiscountsBySecuence.mapSecuenceA996.get(sKeyA996);
        }
        else if(DiscountsBySecuence.mapSecuenceA997.containsKey(sKeyA997)){
            descuentoPromo = DiscountsBySecuence.mapSecuenceA997.get(sKeyA997);
        }
        else if(DiscountsBySecuence.mapSecuence9A40.containsKey(sKey9A40)){
            descuentoPromo = DiscountsBySecuence.mapSecuence9A40.get(sKey9A40);
        }
        System.debug('Descuento promo: '+ descuentoPromo);
        return descuentoPromo;
    }
    
    
    public class WrapperSecuences{
        @AuraEnabled public Map<String,Descuento__c> mapSecuenceA305;
        @AuraEnabled public Map<String,Descuento__c> mapSecuenceA999;
        @AuraEnabled public Map<String,Descuento__c> mapSecuenceA993;
        @AuraEnabled public Map<String,Descuento__c> mapSecuenceA996;
        @AuraEnabled public Map<String,Descuento__c> mapSecuenceA997;
        @AuraEnabled public Map<String,Descuento__c> mapSecuence9A40;
    }
    public class WrapperSecuencesParam{
        @AuraEnabled public String OrgVentas;
        @AuraEnabled public String canalVentas;
        @AuraEnabled public String numeroCliente;
        @AuraEnabled public String numeroMaterial;
        @AuraEnabled public String OficinaVentas;
        @AuraEnabled public String ListaPrecios;
        @AuraEnabled public String GrupoMateriales;
        @AuraEnabled public String GrupoArticulos;
        @AuraEnabled public String GrupoClientes;
        @AuraEnabled public String ClaseDoc;
        @AuraEnabled public String CanalPromocion;
    }

    /*******************************************************************
    Purpose: Genera un objeto Descuento__c
    Parameters: WrapperSecuencesParam Param, WrapperSecuences DiscountsBySecuence
    Returns: Descuento__c 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Descuento__c getDescuento(String codigoSecuencia,IMP_DescuentosManager.T_A000 descuento){
        
        Descuento__c descuentoSF = new Descuento__c(
            IMP_SecuenciaAcceso__c  = codigoSecuencia,
            IMP_ClaseCondicion__c = descuento.KSCHL,
            IMP_OrganizacionVentas__c  = descuento.VKORG,
            IMP_CanalVentas__c = descuento.VTWEG,
            IMP_NumeroCliente__c  = descuento.KUNNR,
            IMP_NumeroMaterial__c  =descuento.MATNR!= null? descuento.MATNR.replaceFirst('^0+', ''):'',
            IMP_ImportePorcentaje__c  =descuento.KBETR != null ?  Decimal.valueOf(descuento.KBETR.trim().replaceAll('-', '')): 0,
            IMP_UnidadCondicion__c  = descuento.KONWA,
            IMP_FechaInicial__c = Date.valueOf(descuento.DATAB.substring(0,4)+'-'+descuento.DATAB.substring(4,6)+'-'+descuento.DATAB.substring(6,8)),
            IMP_FechaFinal__c = descuento.DATBI =='99991231' ? Date.valueOf(2100+'-'+descuento.DATBI.substring(4,6)+'-'+descuento.DATBI.substring(6,8)):Date.valueOf(descuento.DATBI.substring(0,4)+'-'+descuento.DATBI.substring(4,6)+'-'+descuento.DATBI.substring(6,8)),
            IMP_OficinaVentas__c = descuento.VKBUR,
            IMP_Lote__c = descuento.CHARG,
            IMP_ListaPrecios__c = descuento.PLTYP,
            IMP_GrupoClientes__c = descuento.KDGRP,
            IMP_GrupoArticulos__c = descuento.MATKL,
            IMP_GrupoMateriales__c = descuento.KONDM,
            IMP_ClaseDocumentoVentas__c  = descuento.AUART_SD,
            Name =  descuento.KNUMH ,
            IMP_IdExterno__c  = descuento.KNUMH );
        return descuentoSF;
    }
}