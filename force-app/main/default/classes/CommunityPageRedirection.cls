public class CommunityPageRedirection {
    public CommunityPageReference urlRedirectionError() {
        String url = 'https://www.nav.no/error';

        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
    }
}
