module hex (length) {
	D = length;
	alpha = D / 4;
	beta = sqrt(3) * alpha;
	polygon([[0, -2 * alpha],
            [beta, -1 * alpha],
            [beta, alpha],
            [0, 2 * alpha],
            [-1 * beta, alpha],
            [-1 * beta, -1 * alpha]
	]);
}

numHexes = 6;
botR = 200;
topR = 50;
layers = 20;
decR = (botR - topR) / (layers / 2);
echo(decR);

function genPoint (points, i, z, r) = 
	let (
		interval = (360 / (numHexes * 3)),
		start = interval * ((z % 2) * 1.5),
		theta = start + (interval * i))
	z <= layers ? 
		i <= numHexes * 3 ? 
			i % 3 != 0 ? 
				genPoint(concat(points,
								[ [ r * sin(theta),
									r * cos(theta),
									z * (botR + r +topR) / 6
								]]),
						i+1, z, r) : 
				genPoint(points, i+1, z, r) : 
			genPoint(points, 0, z+1, (z + 1) % 2 == 0 ? r - decR : r) :
		points;

points = genPoint([], 0, 0, botR);

for (p=points)
{
	translate(p) sphere(3);
}

function getLayerIndex (i, z) = (i + 2) % (2 * numHexes) == 0 ? z + 1 : z;

function genOddFace (faces, i, z) = 
	let (
			a = i,
			b = i + 1,
			// c = i + 2 * numHexes < (z + 1) * numHexes ? 
			c = (i + 2) % (numHexes * 2) != 0 ?
				i + 2 * numHexes + 2:
				i + 2,
			d = i + 4 * numHexes + 1,
			e = i + 4 * numHexes,
			f = i + 2 * numHexes + 1,
			newFaces = concat(faces, [[a,b,c,d,e,f]]),
			newZ = getLayerIndex(i, z)
		)
	z <= layers - 2 ? 
		newZ % 2 == 0 ? 
			genEvenFace(newFaces, i + 2, newZ) :
			genOddFace(newFaces, i + 2, newZ) :
		faces;

function genEvenFace (faces, i, z) = 
	let (
			a = i,
			b = i + 1,
			c = i + 2 * numHexes,
			d = i + 4 * numHexes + 1,
			e = i + 4 * numHexes,
			f = i + 2 * numHexes - 1 == (z + 1) * 2 * numHexes - 1 ? 
				i + 4 * numHexes - 1 :
				i + 2 * numHexes - 1,
			newFaces = concat(faces, [[a,b,c,d,e,f]]),
			newZ = getLayerIndex(i, z)
		)
	z < layers - 2 ? 
		newZ % 2 == 0 ? 
			genEvenFace(newFaces, i + 2, newZ) :
			genOddFace(newFaces, i + 2, newZ) : 
		faces;

faces = genEvenFace([], 0, 0);
// echo(faces);

polyhedron(points, faces);