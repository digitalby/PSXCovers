//
//  GameURLValidator.swift
//  PSXCovers
//
//  Created by Digital on 24/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

class GameURLValidator {

    fileprivate var hostPattern: String { #"(www\.)?psxdatacenter\.com"# }
    fileprivate var pathPSXPattern: String { #"\/games"# }
    fileprivate var pathRegionPattern: String { pathPSXPattern + #"\/[JPU]"# }
    fileprivate var pathAlphabetGroupPattern: String { pathRegionPattern + #"\/(0-9)|[A-Z]"# }
    //Part 1 - Media: S = CD/DVD.
    //Next-gen consoles use U = UMD, B = Blu-ray, N = Network.
    //Part 2 - Publisher: C = Sony published, L = licensed.
    //Part 3 - Region: E = PAL, U = NTSC-U, P = NTSC-J.
    //Part 4 - Type: S = Software, D = Demo.
    //Some games use M and T. Also, H = Hardware.
    //Part 5 - Item Serial Number: uses -\d{5} pattern for software. Some hardware uses -\d{3-6} .
    //PSXDataCenter has some NTSC-U prototype games marked as -0XXXX
    //There are also games not conformant to this format:
    //PBPX is for PAL/NTSC-U demos.
    //SPUS is for NTSC-U PlayStation Picks.
    //ESPM is for some Sony Music Entertainment discs (NTSC-J).
    //Some NTSC-J games use completely different 4-letter codes.
    //Lightspan discs (NTSC-U) use LSP-\d{6} pattern.
    fileprivate var gamePartEUAlphaCodesPattern: String { #"((S[CL]E[SD])|(PBPX))-\d{5}"# }
    fileprivate var gamePartUSAlphaCodesPattern: String { #"(((S[CLP]US)|(PBPX))-((\d{5})|(0XXXX)))|(LSP-\d{6})"# }
    fileprivate var gamePartJPAlphaCodesPattern: String { #"(([PS][ACIL][BPKZ][ADMSX])|(ESPM))-\d{5}"# }
    fileprivate var pathGamePartNumberPattern: String {
        pathAlphabetGroupPattern
        + #"\/"#
        + "("
        + "(\(gamePartEUAlphaCodesPattern))"
        + "|"
        + "(\(gamePartUSAlphaCodesPattern))"
        + "|"
        + "(\(gamePartJPAlphaCodesPattern))"
        + ")"
    }
    fileprivate var finalPattern: String { pathGamePartNumberPattern + #"(\.html?)?"# }

    func makeValidatedPSXGameURL(urlString: String) throws -> URL {
        //MARK: Init
        let trimmedString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count > 0 else {
            throw GameURLValidationError.invalidURLString
        }
        guard let url = URL(string: trimmedString) else {
            throw GameURLValidationError.urlInitializationFailed
        }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw GameURLValidationError.urlComponentsInitializationFailed
        }
        //MARK: Host
        guard
            let host = urlComponents.host,
            let range = host.range(of: hostPattern, options: [.caseInsensitive, .regularExpression]),
            host[range] == host
        else {
            throw GameURLValidationError.hostIsNotPSXDC
        }
        //MARK: Path
        let path = urlComponents.path
        guard path.range(of: pathPSXPattern, options: [.regularExpression]) != nil else {
            throw GameURLValidationError.invalidPlatformSubpath
        }
        guard path.range(of: pathRegionPattern, options: [.regularExpression]) != nil else {
            throw GameURLValidationError.invalidRegionSubpath
        }
        guard path.range(of: pathAlphabetGroupPattern, options: [.regularExpression]) != nil else {
            throw GameURLValidationError.invalidAlphabetGroupSubpath
        }
        guard path.range(of: finalPattern, options: [.regularExpression]) != nil else {
            throw GameURLValidationError.invalidPSXGameSubpath
        }
        return url
    }
}
