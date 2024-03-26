//
//  MainViewModel.swift
//  Podcasts
//
//  Created by Anton on 16.03.2024.
//

import Foundation

class MainViewModel: IPerRequest, INotifyOnChanged {
    
    typealias Arguments = Void
    
    //MARK: services
    private var apiService: ApiService!
    
    //MARK: init
    required init?(container: any IContainer, args: Arguments) {
        self.apiService = container.resolve()
    }
    
    func fetchTopPodcast() {
        let urlString = DynamicLinkManager.topPodcast.url
        guard let _ = URL(string: urlString) else { return }
    }
}


// MARK: - Welcome
struct Welcome: Codable {
    let feed: Feed
}

// MARK: - Feed
struct Feed: Codable {

    let entry: [Entry]
    let updated, rights, title, icon: Icon
    let link: [Link]
    let id: Icon
}

// MARK: - Icon
struct Icon: Codable {
    let label: String
}

// MARK: - Entry
struct Entry: Codable {
    let imName: Icon
    let imPrice: IMPrice
    let imImage: [IMImage]
    let summary: Icon
    let imArtist: IMArtist
    let title: Icon
    let link: Link
    let id: ID
    let imContentType: IMContentType
    let category: Category
    let imReleaseDate: IMReleaseDate
    let rights: Icon?

    enum CodingKeys: String, CodingKey {
        case imName = "im:name"
        case imPrice = "im:price"
        case imImage = "im:image"
        case summary
        case imArtist = "im:artist"
        case title, link, id
        case imContentType = "im:contentType"
        case category
        case imReleaseDate = "im:releaseDate"
        case rights
    }
}

// MARK: - Category
struct Category: Codable {
    let attributes: CategoryAttributes
}

// MARK: - CategoryAttributes
struct CategoryAttributes: Codable {
    let imID: String
    let term: PurpleLabel
    let scheme: String
    let label: PurpleLabel

    enum CodingKeys: String, CodingKey {
        case imID = "im:id"
        case term, scheme, label
    }
}

enum PurpleLabel: String, Codable {
    case technology = "Technology"
}

// MARK: - ID
struct ID: Codable {
    let label: String
    let attributes: IDAttributes
}

// MARK: - IDAttributes
struct IDAttributes: Codable {
    let imID: String

    enum CodingKeys: String, CodingKey {
        case imID = "im:id"
    }
}

// MARK: - IMArtist
struct IMArtist: Codable {
    let label: String
    let attributes: IMArtistAttributes?
}

// MARK: - IMArtistAttributes
struct IMArtistAttributes: Codable {
    let href: String
}

// MARK: - IMContentType
struct IMContentType: Codable {
    let attributes: IMContentTypeAttributes
}

// MARK: - IMContentTypeAttributes
struct IMContentTypeAttributes: Codable {
    let term, label: FluffyLabel
}

enum FluffyLabel: String, Codable {
    case podcast = "Podcast"
}

// MARK: - IMImage
struct IMImage: Codable {
    let label: String
    let attributes: IMImageAttributes
}

// MARK: - IMImageAttributes
struct IMImageAttributes: Codable {
    let height: String
}

// MARK: - IMPrice
struct IMPrice: Codable {
    let label: IMPriceLabel
    let attributes: IMPriceAttributes
}

// MARK: - IMPriceAttributes
struct IMPriceAttributes: Codable {
    let amount: String
    let currency: Currency
}

enum Currency: String, Codable {
    case usd = "USD"
}

enum IMPriceLabel: String, Codable {
    case labelGet = "Get"
}

// MARK: - IMReleaseDate
struct IMReleaseDate: Codable {
    let label: String
    let attributes: Icon
}

// MARK: - Link
struct Link: Codable {
    let attributes: LinkAttributes
}

// MARK: - LinkAttributes
struct LinkAttributes: Codable {
    let rel: Rel
    let type: TypeEnum?
    let href: String
}

enum Rel: String, Codable {
    case alternate = "alternate"
    case relSelf = "self"
}

enum TypeEnum: String, Codable {
    case textHTML = "text/html"
}














//
//
//{"feed":{"author":{"name":{"label":"iTunes Store"}, "uri":{"label":"http://www.apple.com/itunes/"}}, "entry":[
//{"im:name":{"label":"Lex Fridman Podcast"}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Conversations about science, technology, history, philosophy and the nature of intelligence, consciousness, love, and power. Lex is an AI researcher at MIT and beyond."}, "im:artist":{"label":"Lex Fridman"}, "title":{"label":"Lex Fridman Podcast - Lex Fridman"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/lex-fridman-podcast/id1434243584?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/lex-fridman-podcast/id1434243584?uo=2", "attributes":{"im:id":"1434243584"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-14T07:59:00-07:00", "attributes":{"label":"March 14, 2024"}}},
//{"im:name":{"label":"All-In with Chamath, Jason, Sacks & Friedberg"}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts124/v4/c7/d2/92/c7d292ea-44b3-47ff-2f5e-74fa5b23db6c/mza_7005270671777648882.png/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts124/v4/c7/d2/92/c7d292ea-44b3-47ff-2f5e-74fa5b23db6c/mza_7005270671777648882.png/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts124/v4/c7/d2/92/c7d292ea-44b3-47ff-2f5e-74fa5b23db6c/mza_7005270671777648882.png/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Industry veterans, degenerate gamblers & besties Chamath Palihapitiya, Jason Calacanis, David Sacks & David Friedberg cover all things economic, tech, political, social & poker."}, "im:artist":{"label":"All-In Podcast, LLC"}, "title":{"label":"All-In with Chamath, Jason, Sacks & Friedberg - All-In Podcast, LLC"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/all-in-with-chamath-jason-sacks-friedberg/id1502871393?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/all-in-with-chamath-jason-sacks-friedberg/id1502871393?uo=2", "attributes":{"im:id":"1502871393"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-08T13:56:00-07:00", "attributes":{"label":"March 8, 2024"}}},
//{"im:name":{"label":"No Priors: Artificial Intelligence | Machine Learning | Technology | Startups"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/a6/4d/9c/a64d9c5a-2ca4-6a1b-3ceb-424efe00d022/mza_1247466525586262525.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/a6/4d/9c/a64d9c5a-2ca4-6a1b-3ceb-424efe00d022/mza_1247466525586262525.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/a6/4d/9c/a64d9c5a-2ca4-6a1b-3ceb-424efe00d022/mza_1247466525586262525.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"At this moment of inflection in technology, co-hosts Elad Gil and Sarah Guo talk to the world's leading AI engineers, researchers and founders about the biggest questions: How far away is AGI? What markets are at risk for disruption? How will commerce, culture, and society change? What’s happening in state-of-the-art in research? “No Priors” is your guide to the AI revolution. Email feedback to show@no-priors.com.\nSarah Guo is a startup investor and the founder of Conviction, an investment firm purpose-built to serve intelligent software, or \"Software 3.0\" companies. She spent nearly a decade incubating and investing at venture firm Greylock Partners.\nElad Gil is a serial entrepreneur and a startup investor. He was co-founder of Color Health, Mixer Labs (which was acquired by Twitter). He has invested in over 40 companies now worth $1B or more each, and is also author of the High Growth Handbook."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© Copyright 2023 Conviction. All Rights Reserved."}, "title":{"label":"No Priors: Artificial Intelligence | Machine Learning | Technology | Startups - Conviction | Pod People"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/no-priors-artificial-intelligence-machine-learning/id1668002688?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/no-priors-artificial-intelligence-machine-learning/id1668002688?uo=2", "attributes":{"im:id":"1668002688"}}, "im:artist":{"label":"Conviction | Pod People"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-14T03:00:00-07:00", "attributes":{"label":"March 14, 2024"}}},
//{"im:name":{"label":"Hard Fork"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/90/c6/68/90c6680c-0ad0-ac08-b2c8-6bda5f057654/mza_11004870069464171643.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/90/c6/68/90c6680c-0ad0-ac08-b2c8-6bda5f057654/mza_11004870069464171643.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/90/c6/68/90c6680c-0ad0-ac08-b2c8-6bda5f057654/mza_11004870069464171643.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"“Hard Fork” is a show about the future that’s already here. Each week, journalists Kevin Roose and Casey Newton explore and make sense of the latest in the rapidly changing world of tech. \n\nListen to this podcast in New York Times Audio, our new iOS app for news subscribers. Download now at nytimes.com/audioapp"}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© 2022 THE NEW YORK TIMES COMPANY; The New York Times encourages the use of RSS feeds for personal use in a news reader or as part of a non-commercial blog, subject to your agreement to our Terms of Service."}, "title":{"label":"Hard Fork - The New York Times"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/hard-fork/id1528594034?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/hard-fork/id1528594034?uo=2", "attributes":{"im:id":"1528594034"}}, "im:artist":{"label":"The New York Times", "attributes":{"href":"https://podcasts.apple.com/us/artist/the-new-york-times/121664449?uo=2"}}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-15T02:00:00-07:00", "attributes":{"label":"March 15, 2024"}}},
//{"im:name":{"label":"TED Radio Hour"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/e4/23/90/e4239057-ff9b-0ced-9d7b-5fd2727077e7/mza_249251147727353095.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/e4/23/90/e4239057-ff9b-0ced-9d7b-5fd2727077e7/mza_249251147727353095.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/e4/23/90/e4239057-ff9b-0ced-9d7b-5fd2727077e7/mza_249251147727353095.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Exploring the biggest questions of our time with the help of the world's greatest thinkers. Host Manoush Zomorodi inspires us to learn more about the world, our communities, and most importantly, ourselves.Get more brainy miscellany with TED Radio Hour+. Your subscription supports the show and unlocks a sponsor-free feed. Learn more at plus.npr.org/ted"}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© Copyright 2012-2021 NPR and Ted Conferences, LLC - For Personal Use Only"}, "title":{"label":"TED Radio Hour - NPR"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/ted-radio-hour/id523121474?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/ted-radio-hour/id523121474?uo=2", "attributes":{"im:id":"523121474"}}, "im:artist":{"label":"NPR", "attributes":{"href":"https://podcasts.apple.com/us/artist/npr/125443881?uo=2"}}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-15T00:00:00-07:00", "attributes":{"label":"March 15, 2024"}}},
//{"im:name":{"label":"Deep Questions with Cal Newport"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/72/76/4f/72764fe5-ce0e-6af9-4f22-cf133dfd4348/mza_15248579015902949914.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/72/76/4f/72764fe5-ce0e-6af9-4f22-cf133dfd4348/mza_15248579015902949914.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/72/76/4f/72764fe5-ce0e-6af9-4f22-cf133dfd4348/mza_15248579015902949914.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Cal Newport is a computer science professor and a New York Times bestselling author who writes about the impact of technology on society, and the struggle to work and live deeply in a world increasingly mired in digital distractions. On this podcast, he answers questions from his readers and offers advice about cultivating focus, productivity, and meaning amidst the noise that pervades our lives."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© 2024 Deep Questions with Cal Newport"}, "title":{"label":"Deep Questions with Cal Newport - Cal Newport"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/deep-questions-with-cal-newport/id1515786216?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/deep-questions-with-cal-newport/id1515786216?uo=2", "attributes":{"im:id":"1515786216"}}, "im:artist":{"label":"Cal Newport"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-04T04:00:00-07:00", "attributes":{"label":"March 4, 2024"}}},
//{"im:name":{"label":"Acquired"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/b3/68/f7/b368f77a-72d5-2643-7ed7-b873066758e0/mza_5580436457903834475.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/b3/68/f7/b368f77a-72d5-2643-7ed7-b873066758e0/mza_5580436457903834475.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts126/v4/b3/68/f7/b368f77a-72d5-2643-7ed7-b873066758e0/mza_5580436457903834475.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Every company has a story.\n\nLearn the playbooks that built the world’s greatest companies — and how you can apply them as a founder, operator, or investor."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© Copyright 2023 ACQ, LLC"}, "title":{"label":"Acquired - Ben Gilbert and David Rosenthal"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/acquired/id1050462261?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/acquired/id1050462261?uo=2", "attributes":{"im:id":"1050462261"}}, "im:artist":{"label":"Ben Gilbert and David Rosenthal"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-02-19T17:56:00-07:00", "attributes":{"label":"February 19, 2024"}}},
//{"im:name":{"label":"Better Offline"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/76/2c/8f/762c8fac-7a9a-fcf1-afb9-d07ecd6d926f/mza_13895507990680118686.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/76/2c/8f/762c8fac-7a9a-fcf1-afb9-d07ecd6d926f/mza_13895507990680118686.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/76/2c/8f/762c8fac-7a9a-fcf1-afb9-d07ecd6d926f/mza_13895507990680118686.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Better Offline is a weekly show exploring the tech industry’s influence and manipulation of society - and interrogating the growth-at-all-costs future that tech’s elite wants to build. \n\nCombining narrative-form storytelling, one-on-one interviews and panel-based discussions, Better Offline cuts through the buzzwords and obfuscation of the tech industry, investigating and evaluating the schemes and scams of everyone from cryptocurrency scumbags to the greediest of the venture capital elite. Tech industry veteran Ed Zitron and a dynamic coterie of guests will help listeners understand the who, how and why of how tech’s most powerful players are changing the world - for better or for worse."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"2024 iHeartMedia, Inc. © Any use of this intellectual property for text and data mining or computational analysis including as training material for artificial intelligence systems is strictly prohibited without express written consent from iHeartMedia"}, "title":{"label":"Better Offline - Cool Zone Media"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/better-offline/id1730587238?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/better-offline/id1730587238?uo=2", "attributes":{"im:id":"1730587238"}}, "im:artist":{"label":"Cool Zone Media"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-12T21:00:00-07:00", "attributes":{"label":"March 12, 2024"}}},
//{"im:name":{"label":"Darknet Diaries"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/3a/80/a7/3a80a7db-5620-f77b-9935-016e61cc2fbc/mza_9399859904175514567.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/3a/80/a7/3a80a7db-5620-f77b-9935-016e61cc2fbc/mza_9399859904175514567.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts122/v4/3a/80/a7/3a80a7db-5620-f77b-9935-016e61cc2fbc/mza_9399859904175514567.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Explore true stories of the dark side of the Internet with host Jack Rhysider as he takes you on a journey through the chilling world of hacking, data breaches, and cyber crime."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© Jack Rhysider"}, "title":{"label":"Darknet Diaries - Jack Rhysider"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/darknet-diaries/id1296350485?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/darknet-diaries/id1296350485?uo=2", "attributes":{"im:id":"1296350485"}}, "im:artist":{"label":"Jack Rhysider"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-05T00:00:00-07:00", "attributes":{"label":"March 5, 2024"}}},
//{"im:name":{"label":"Endless Thread"}, "im:image":[
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/fb/17/53/fb175385-8d52-ecf9-5268-cbf7a3a67b1f/mza_9060456912121241658.jpg/55x55bb.png", "attributes":{"height":"55"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/fb/17/53/fb175385-8d52-ecf9-5268-cbf7a3a67b1f/mza_9060456912121241658.jpg/60x60bb.png", "attributes":{"height":"60"}},
//{"label":"https://is1-ssl.mzstatic.com/image/thumb/Podcasts116/v4/fb/17/53/fb175385-8d52-ecf9-5268-cbf7a3a67b1f/mza_9060456912121241658.jpg/170x170bb.png", "attributes":{"height":"170"}}], "summary":{"label":"Hosts Ben Brock Johnson and Amory Sivertson dig into the internet's vast and curious ecosystem of online communities to find untold histories, unsolved mysteries, and other jaw-dropping stories online and IRL."}, "im:price":{"label":"Get", "attributes":{"amount":"0", "currency":"USD"}}, "im:contentType":{"attributes":{"term":"Podcast", "label":"Podcast"}}, "rights":{"label":"© Copyright Trustees of Boston University"}, "title":{"label":"Endless Thread - WBUR"}, "link":{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/us/podcast/endless-thread/id1321060753?uo=2"}}, "id":{"label":"https://podcasts.apple.com/us/podcast/endless-thread/id1321060753?uo=2", "attributes":{"im:id":"1321060753"}}, "im:artist":{"label":"WBUR"}, "category":{"attributes":{"im:id":"1318", "term":"Technology", "scheme":"https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2", "label":"Technology"}}, "im:releaseDate":{"label":"2024-03-15T02:00:00-07:00", "attributes":{"label":"March 15, 2024"}}}], "updated":{"label":"2024-03-16T10:35:56-07:00"}, "rights":{"label":"Copyright 2008 Apple Inc."}, "title":{"label":"iTunes Store: Top Podcasts in Technology"}, "icon":{"label":"http://itunes.apple.com/favicon.ico"}, "link":[
//{"attributes":{"rel":"alternate", "type":"text/html", "href":"https://podcasts.apple.com/WebObjects/MZStore.woa/wa/viewTop?cc=us&id=179584&popId=3"}},
//{"attributes":{"rel":"self", "href":"https://mzstoreservices-int.itunes.apple.com/us/rss/toppodcasts/limit=10/genre=1318/json"}}], "id":{"label":"https://mzstoreservices-int.itunes.apple.com/us/rss/toppodcasts/limit=10/genre=1318/json"}}}
