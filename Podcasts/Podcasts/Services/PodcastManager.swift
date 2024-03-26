//
//  PodcastManager.swift
//  Podcasts
//
//  Created by Anton on 18.03.2024.
//

import Foundation


class PodcastManager: ISingleton {
    
    typealias Arguments = Void
    
    private var apiService: ApiService
    
    required init(container: any IContainer, args: Void) {
        self.apiService = container.resolve()
    }
}


extension PodcastManager {
    
    typealias Output<T> = @MainActor (Result<T, MyError.PodcastManager>) async -> Void
    
    func getPodcastEpisodeByCollectionId(id: Int, completion: @escaping Output<[Podcast]>) {
        
        let url = DynamicLinkManager.podcastEpisodeByCollectionId(id).url
        
        apiService.getData(PodcastData.self, for: url) { [weak self] result in
            guard let _ = self else { return }
            
            Task {
                switch result {
                    
                case .failure(let error):
                    await completion(.failure(.netWorkError(error)))
                    
                case .success(result: let podcastData):
                    let podcasts = podcastData.podcasts.filter {
                        if $0.wrapperType == "track" {
                            return true
                        } else if $0.wrapperType == "podcastEpisode" {
                            return true
                        }
                        fatalError()
                    }
                    await completion(.success(result: podcasts))
                }
            }
        }
    }
    
    func getPodcasts(by type: DynamicLinkManager, completion: @escaping Output<[Podcast]>) {
        let url = type.url
        
        Task { [weak self] in
            guard let self = self else { return }
            let result = await self.apiService.getData(PodcastData.self, for: url)
            
                switch result {
                case .failure(let apiError):
                    await completion(.failure(.netWorkError(apiError)))
                case .success(result: let podcastData):
                    if let podcasts = podcastData.results.allObjects as? [Podcast] {
                        await completion(.success(result: podcasts))
                    }
            }
        }
    }
    
    /// -------------
    typealias PodcastsByAuthor = (authorName: String, podcasts: [Podcast])
    
    func getPodcasts(byAuthorName name: String, completion: @escaping Output<[PodcastsByAuthor]>) {
        
        var podcastsByAuthor = [PodcastsByAuthor]()
        var count = 0
        
        getAuthors(byName: name) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .failure(let error):
                await completion(.failure(error))
                
            case .success(result: let authors):
                getPodcasts(forAuthors: authors)
            }
            
            func getPodcasts(forAuthors authors: [Author]) {
                authors.forEach { author in
                    if let name = author.artistName, !name.isEmpty {
                        let id = author.artistID.intValue
                        self.getPodcasts(by: .podcastByAuthorId(id)) { [weak self] results in
                            guard let _ = self else { return }
                            
                            switch results {
                                
                            case .success(result: let podcasts):
                                let podcasts = podcasts.filter { $0.wrapperType != "artist" }
                                if !podcasts.isEmpty {
                                    podcastsByAuthor.append((authorName: name, podcasts: podcasts))
                                }
                                
                            case .failure(let error):
                                await completion(.failure(error))
                            }
                            
                            count += 1
                            if count == authors.count {
                                if podcastsByAuthor.isEmpty {
                                    await completion(.failure(.noData(request: name)))
                                } else {
                                    await completion(.success(result: podcastsByAuthor))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getAuthors(byName name: String, completion: @escaping Output<[Author]>) {
        let url = DynamicLinkManager.authors(name).url
        
        apiService.getData(AuthorData.self, for: url) { [weak self] result in
            guard let _ = self else { return }
            Task {
                switch result {
                case .success(result: let authorData) :
                    if let authors = authorData.results?.allObjects as? [Author], !authors.isEmpty {
                        await completion(.success(result: authors))
                    } else {
                        await completion(.failure(.noData(request: name)))
                    }
                case .failure(error: let error) :
                    await completion(.failure(.netWorkError(error)))
                }
            }
        }
    }
}

