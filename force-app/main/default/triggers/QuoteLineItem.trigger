trigger QuoteLineItem on QuoteLineItem (before insert, before update) {
    switch on trigger.operationType{
        when AFTER_UPDATE {

        }
        when BEFORE_INSERT{
            IMP_HandleDescuentos.applyDiscounts(trigger.new);
        }         
     
    }
}