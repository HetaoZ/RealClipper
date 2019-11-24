module RealClipper
import Clipper
# Callable functions
"Parameters L and Center are for regularization."
function poly_inter_area(ClipX::Vector,ClipY::Vector,SubjX::Vector,SubjY::Vector,L::Real,CenterX::Real,CenterY::Real)
    clip = getrealpoly(ClipX,ClipY,L,CenterX,CenterY)
    subj = getrealpoly(SubjX,SubjY,L,CenterX,CenterY)
    a = getpolyinterarea(clip,subj)
    return a * L * L / 1.e14
end

# Assistant functions
function getrealpoly(x::Vector,y::Vector,L::Real,CenterX::Real,CenterY::Real)
    x, y = map(Int,map(round,(x .- CenterX) ./ L .* 1.e7)), map(Int,map(round,(y .- CenterY) ./ L .* 1.e7))
    return getpoly(x,y)
end
function getpoly(x::Vector{Int},y::Vector{Int})
    n=length(x)
    p=Vector{Clipper.IntPoint}(undef,n)
    for i=1:n
        p[i]=Clipper.IntPoint(x[i],y[i])
    end
    return p
end
function interarea(c::Clipper.Clip)
    r=Clipper.execute(c,Clipper.ClipTypeIntersection,Clipper.PolyFillTypePositive,Clipper.PolyFillTypePositive)
    try
        return Clipper.area(r[2][1])
    catch
        return 0
    end
end
function getpolyinterarea(clip::Array{Clipper.IntPoint,1},subject::Array{Clipper.IntPoint,1})
    c=Clipper.Clip()
    Clipper.add_path!(c,clip,Clipper.PolyTypeClip,true)
    Clipper.add_path!(c,subject,Clipper.PolyTypeSubject,true)
    return interarea(c)
end
end
