//
//  ViewController.swift
//  Podcasts
//
//  Created by Anton on 16.03.2024.
//

import UIKit


class MainViewController: UIViewController, IHaveStoryBoardAndViewModel {
    
    typealias Args = Void
    typealias ViewModel = MainViewModel
    
   @IBOutlet private weak var imageView: UIImageView!
   
   @IBOutlet private weak var collectionView: UICollectionView!
   
    //MARK: init
    required init?(container: IContainer, args: (args: Args, coder: NSCoder)) {
        super.init(coder: args.coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController {
   //MARK: View Methods
  
  func configureUI() {
      viewModel.fetchTopPodcast()
  }
    func updateUI() {}
  
   override func viewDidLoad() {
       super.viewDidLoad()
       configureUI()
       updateUI()
   }
}


//{
//    category =                 {
//        attributes =                     {
//            "im:id" = 1318;
//            label = Technology;
//            scheme = "https://podcasts.apple.com/us/genre/podcasts-technology/id1318?uo=2";
//            term = Technology;
//        };
//    };
//    id =                 {
//        attributes =                     {
//            "im:id" = 1434243584;
//        };
//        label = "https://podcasts.apple.com/us/podcast/lex-fridman-podcast/id1434243584?uo=2";
//    };
//    "im:artist" =                 {
//        label = "Lex Fridman";
//    };
//    "im:contentType" =                 {
//        attributes =                     {
//            label = Podcast;
//            term = Podcast;
//        };
//    };
//    "im:image" =                 (
//        {
//            attributes =                         {
//                height = 55;
//            };
//            label = "https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/55x55bb.png";
//        },
//        {
//            attributes =                         {
//                height = 60;
//            };
//            label = "https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/60x60bb.png";
//        },
//        {
//            attributes =                         {
//                height = 170;
//            };
//            label = "https://is1-ssl.mzstatic.com/image/thumb/Podcasts115/v4/3e/e3/9c/3ee39c89-de08-47a6-7f3d-3849cef6d255/mza_16657851278549137484.png/170x170bb.png";
//        }
//    );
//    "im:name" =                 {
//        label = "Lex Fridman Podcast";
//    };
//    "im:price" =                 {
//        attributes =                     {
//            amount = 0;
//            currency = USD;
//        };
//        label = Get;
//    };
//    "im:releaseDate" =                 {
//        attributes =                     {
//            label = "March 14, 2024";
//        };
//        label = "2024-03-14T07:59:00-07:00";
//    };
//    link =                 {
//        attributes =                     {
//            href = "https://podcasts.apple.com/us/podcast/lex-fridman-podcast/id1434243584?uo=2";
//            rel = alternate;
//            type = "text/html";
//        };
//    };
//    summary =                 {
//        label = "Conversations about science, technology, history, philosophy and the nature of intelligence, consciousness, love, and power. Lex is an AI researcher at MIT and beyond.";
//    };
//    title =                 {
//        label = "Lex Fridman Podcast - Lex Fridman";
//    };
//}
