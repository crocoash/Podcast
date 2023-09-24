//
//  BaseSectionData.swift
//  Podcasts
//
//  Created by Anton on 23.09.2023.
//

import Foundation

protocol ISectionData: Equatable {
    associatedtype Row: Identifiable
    associatedtype Section: Equatable
    
    var section: Section { get set }
    var rows: [Row]      { get set }
    var isActive: Bool   { get }
}


extension ISectionData {
    var isEmpty: Bool { rows.isEmpty }
}

class BaseSectionData<Row, Section>: ISectionData {
    
    static func == (lhs: BaseSectionData<Row, Section>, rhs: BaseSectionData<Row, Section>) -> Bool {
        lhs.rows == rhs.rows
    }
  
    var section: String
    var rows: [Podcast]
    var isActive: Bool = true
    
    init(section: String, rows: [Podcast]) {
        self.section = section
        self.rows = rows
    }
}


//MARK: - extension Collection
extension Collection where Element == Podcast {
    
    typealias SectionData = BaseSectionData<Podcast, String>

    var sortPodcastsByGenre: [SectionData] {
        var array = [SectionData]()

        for podcast in self {
            if let genres = podcast.genres?.allObjects as? [Genre] {
            loop: for genre in genres {
                if let genreName = genre.name {
                    if genreName == "Podcasts" {
                        continue loop
                    }

                    if array.isEmpty {
                        array.append(SectionData(section: genreName, rows: [podcast]))
                        continue loop
                    }
                    for (index,value) in array.enumerated() {
                        if value.section == genreName {
                            array[index].rows.append(podcast)
                            continue loop
                        }
                    }
                    array.append(SectionData(section: genreName, rows: [podcast]))
                }
            }
            }
        }
        let filteredArray = array.filter { !$0.rows.isEmpty }
        let sortedArray = filteredArray.map { SectionData(section: $0.section, rows: $0.rows.sorted { $0.releaseDateInformation < $1.releaseDateInformation })}
        return sortedArray
    }

    var sortPodcastsByNewest: [SectionData] {
        let array = self.sorted { $0.releaseDateInformation > $1.releaseDateInformation }
        return array.conform
    }
    
    var sortPodcastsByOldest: [SectionData] {
        let array = self.sorted { $0.releaseDateInformation < $1.releaseDateInformation }
        return array.conform
    }
   
    private var conform: [SectionData] {
        
        var array = [SectionData]()
        loop: for element in self {
            let date = element.formattedDate(dateFormat: "d MMM YYY")
            if array.isEmpty {
                let sectionData = SectionData(section: date, rows: [element])
                array.append(sectionData)
                continue
            }
            for value in array.enumerated() where value.element.section == date  {
                array[value.offset].rows.append(element)
                continue loop
            }
            array.append(SectionData(section: date, rows: [element]))
        }
        return array
    }
}
