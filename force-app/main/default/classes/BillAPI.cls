public with sharing class BillAPI {
    public static List<Bill__c> getBills() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:BillingAPI');
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse responseBody = http.send(request);
        if(responseBody.getStatusCode() == 200) {
            //System.debug(responseBody.getBody());
        }
        List<BillWrapper> bwList = (List<BillWrapper>)JSON.deserialize(responseBody.getBody(), List<BillWrapper>.class);
        
        List<Account> lstAcc = [Select Id,Name from Account where Active__c = 'Yes'];
        Map<String,Id> mapAccNameId = new Map<String,Id>();
        for(Account acc:lstAcc)
        {
            mapAccNameId.put(acc.Name,acc.Id);
        }
        List<Bill__c> lstBill = new List<Bill__c>();
        for(BillWrapper bw:bwList)
        {
            if(mapAccNameId.containsKey(bw.accountName))
            {
                Bill__c bill = new Bill__c(
                    Bill_Id__c=bw.billId,
                    Account__c=mapAccNameId.get(bw.accountName),
                    Balance__c=Decimal.valueOf(bw.balance.replace('$','')));
                lstBill.add(bill);
            }
        }
        system.debug('Size of Bill records: '+lstBill.Size());
        insert lstBill;

        List<Bill__c> lstBillIns = [select Id,Bill_Id__c,Account__c,Balance__c from Bill__c];
        return lstBillIns;
    }
    public class BillWrapper {
        public String billId;
        public String accountName;
        public String balance;
        
    }
}