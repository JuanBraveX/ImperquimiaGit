global class IMP_PriceJOB implements Schedulable {
    
    global void execute(SchedulableContext ctx) {  
        IMP_PriceManager.getPrices();
        //  System.schedule('SCHEDULER PRECIOS', '0 15 7 * * ? * MON-FRI', new IMP_PriceJOB());
    }
    
}