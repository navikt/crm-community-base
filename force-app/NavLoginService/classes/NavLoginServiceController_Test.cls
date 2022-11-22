@IsTest
public with sharing class NavLoginServiceController_Test {
    @IsTest
    private static void redirect_whenRetUrlAsParameter() {

        Pagereference pageRef = Page.NavLoginService;
        Test.startTest();
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('retUrl', '/');
        pageRef.getHeaders().put('Host', 'test.com');
        NavLoginServiceController controller = new NavLoginServiceController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
       
        System.assertEquals(
            'https://loginservice.dev.nav.no/login?redirect=https%3A%2F%2Ftest.com%2Fapex%2FNavLoginService',
            nextPage,
            'Expect redirect to loginservice'
        );
    }

    @IsTest
    private static void redirect_whenNoParameter() {
         Cookie retUrlCookie = new Cookie('retUrl','/',null,-1,true);
         Pagereference pageRef = Page.NavLoginService;
         pageRef.setCookies(new Cookie[]{retUrlCookie });

        Test.startTest();
        test.setCurrentPage(pageRef);
        NavLoginServiceController controller = new NavLoginServiceController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

       
        System.assertEquals(
            '/',
            nextPage,
            'Expect redirect to ret url'
        );
    }

}
