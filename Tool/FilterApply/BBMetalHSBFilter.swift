//
//  BBMetalHSBFilter.swift
//  ImageWizard
//
//  Created by 万孟超 on 2024/5/16.
//

import BBMetalImage
import Metal
import simd

class BBMetalHSBFilter: BBMetalBaseFilter {
    /// A 4x4 matrix used to transform each color in an image
    public var colorMatrix: matrix_float4x4
    /// The degree to which the new transformed color replaces the original color for each pixel
    public var intensity: Float
    
    public init(colorMatrix: matrix_float4x4 = .identity, intensity: Float = 1) {
        self.intensity = intensity
        self.colorMatrix = colorMatrix
        super.init(kernelFunctionName: "colorMatrixKernel")
        reset()
    }
    
    public override func updateParameters(for encoder: MTLComputeCommandEncoder, texture: BBMetalTexture) {
        encoder.setBytes(&intensity, length: MemoryLayout<Float>.size, index: 0)
        encoder.setBytes(&colorMatrix, length: MemoryLayout<matrix_float4x4>.size, index: 1)
    }

    private var matrix: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)

    func reset() {
        identmat(&matrix)
        updateColorMatrix()
    }

    func rotateHue(_ h: Float) {
        huerotatemat(&matrix, h)
        updateColorMatrix()
    }

    func adjustSaturation(_ s: Float) {
        saturatemat(&matrix, s)
        updateColorMatrix()
    }

    func adjustBrightness(_ b: Float) {
        cscalemat(&matrix, b, b, b)
        updateColorMatrix()
    }

    private func updateColorMatrix() {
        let gpuMatrix = matrix_float4x4(rows: [SIMD4<Float>(matrix[0][0], matrix[0][1], matrix[0][2], matrix[0][3]),
                                                SIMD4<Float>(matrix[1][0], matrix[1][1], matrix[1][2], matrix[1][3]),
                                                SIMD4<Float>(matrix[2][0], matrix[2][1], matrix[2][2], matrix[2][3]),
                                                SIMD4<Float>(matrix[3][0], matrix[3][1], matrix[3][2], matrix[3][3])])
                                                    
        self.colorMatrix = gpuMatrix
    }
}

private func matrixmult(_ a: [[Float]], _ c: inout [[Float]]) {
    var temp: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    for y in 0..<4 {
        for x in 0..<4 {
            temp[y][x] = c[y][0] * a[0][x]
                + c[y][1] * a[1][x]
                + c[y][2] * a[2][x]
                + c[y][3] * a[3][x]
        }
    }
    for y in 0..<4 {
        for x in 0..<4 {
            c[y][x] = temp[y][x]
        }
    }
}

private func identmat(_ matrix: inout [[Float]]) {
    matrix = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    matrix[0][0] = 1.0
    matrix[1][1] = 1.0
    matrix[2][2] = 1.0
    matrix[3][3] = 1.0
}

private func xformpnt(_ matrix: [[Float]], _ x: Float, _ y: Float, _ z: Float, _ tx: inout Float, _ ty: inout Float, _ tz: inout Float) {
    tx = x * matrix[0][0] + y * matrix[1][0] + z * matrix[2][0] + matrix[3][0]
    ty = x * matrix[0][1] + y * matrix[1][1] + z * matrix[2][1] + matrix[3][1]
    tz = x * matrix[0][2] + y * matrix[1][2] + z * matrix[2][2] + matrix[3][2]
}

private func cscalemat(_ mat: inout [[Float]], _ rscale: Float, _ gscale: Float, _ bscale: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    mmat[0][0] = rscale
    mmat[1][1] = gscale
    mmat[2][2] = bscale
    mmat[3][3] = 1.0
    matrixmult(mmat, &mat)
}

private func saturatemat(_ mat: inout [[Float]], _ sat: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    let rwgt: Float = 0.3, gwgt: Float = 0.59, bwgt: Float = 0.11

    let a = (1.0 - sat) * rwgt + sat
    let b = (1.0 - sat) * rwgt
    let c = (1.0 - sat) * rwgt
    let d = (1.0 - sat) * gwgt
    let e = (1.0 - sat) * gwgt + sat
    let f = (1.0 - sat) * gwgt
    let g = (1.0 - sat) * bwgt
    let h = (1.0 - sat) * bwgt
    let i = (1.0 - sat) * bwgt + sat

    mmat[0][0] = a
    mmat[0][1] = b
    mmat[0][2] = c
    mmat[1][0] = d
    mmat[1][1] = e
    mmat[1][2] = f
    mmat[2][0] = g
    mmat[2][1] = h
    mmat[2][2] = i
    mmat[3][3] = 1.0

    matrixmult(mmat, &mat)
}

private func xrotatemat(_ mat: inout [[Float]], _ rs: Float, _ rc: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    mmat[0][0] = 1.0
    mmat[1][1] = rc
    mmat[1][2] = rs
    mmat[2][1] = -rs
    mmat[2][2] = rc
    mmat[3][3] = 1.0
    matrixmult(mmat, &mat)
}

private func yrotatemat(_ mat: inout [[Float]], _ rs: Float, _ rc: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    mmat[0][0] = rc
    mmat[0][2] = -rs
    mmat[1][1] = 1.0
    mmat[2][0] = rs
    mmat[2][2] = rc
    mmat[3][3] = 1.0
    matrixmult(mmat, &mat)
}

private func zrotatemat(_ mat: inout [[Float]], _ rs: Float, _ rc: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    mmat[0][0] = rc
    mmat[0][1] = rs
    mmat[1][0] = -rs
    mmat[1][1] = rc
    mmat[2][2] = 1.0
    mmat[3][3] = 1.0
    matrixmult(mmat, &mat)
}

private func zshearmat(_ mat: inout [[Float]], _ dx: Float, _ dy: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    mmat[0][0] = 1.0
    mmat[0][2] = dx
    mmat[1][1] = 1.0
    mmat[1][2] = dy
    mmat[2][2] = 1.0
    mmat[3][3] = 1.0
    matrixmult(mmat, &mat)
}

private func huerotatemat(_ mat: inout [[Float]], _ rot: Float) {
    var mmat: [[Float]] = Array(repeating: Array(repeating: 0.0, count: 4), count: 4)
    identmat(&mmat)

    /* rotate the grey vector into positive Z */
    let mag: Float = sqrt(2.0)
    let xrs = 1.0 / mag
    let xrc = 1.0 / mag
    xrotatemat(&mmat, xrs, xrc)
    let mag2: Float = sqrt(3.0)
    let yrs: Float = -1.0 / mag2
    let yrc: Float = sqrt(2.0) / mag2
    yrotatemat(&mmat, yrs, yrc)

    /* shear the space to make the luminance plane horizontal */
    var lx: Float = 0, ly: Float = 0, lz: Float = 0
    xformpnt(mmat, 0.215, 0.7154, 0.0721, &lx, &ly, &lz)
    let zsx = lx / lz
    let zsy = ly / lz
    zshearmat(&mmat, zsx, zsy)

    /* rotate the hue */
    let zrs = sin(rot * Float.pi / 180.0)
    let zrc = cos(rot * Float.pi / 180.0)
    zrotatemat(&mmat, zrs, zrc)
    
    /* unshear the space to put the luminance plane back */
    zshearmat(&mmat, -zsx, -zsy)
    
    
    /* rotate the grey vector back into place */
    yrotatemat(&mmat, -yrs, yrc)
    xrotatemat(&mmat, -xrs, xrc)
    
    matrixmult(mmat, &mat)
}
