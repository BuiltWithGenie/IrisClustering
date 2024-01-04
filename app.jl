using Clustering, PlotlyBase
import RDatasets: dataset
import DataFrames

using GenieFramework
@genietools

const data = DataFrames.insertcols!(dataset("datasets", "iris"), :Cluster => zeros(Int, 150))
const features = [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]

function cluster(no_of_clusters=3, no_of_iterations=10)
    feats = Matrix(data[:, [c for c in features]])' |> collect
    result = kmeans(feats, no_of_clusters; maxiter=no_of_iterations)
    data[!, :Cluster] = assignments(result)
end

@handlers begin
    @out features
    @in no_of_clusters = 3
    @in no_of_iterations = 10
    @in xfeature = :SepalLength
    @in yfeature = :SepalWidth
    @out datatable = DataTable()
    @out datatablepagination = DataTablePagination(rows_per_page=50)
    @out traces_iris = [scatter()]
    @out traces_cluster = [scatter()]
    @out layout = PlotlyBase.Layout()

    @onchange isready, xfeature, yfeature, no_of_clusters, no_of_iterations begin
        cluster(no_of_clusters, no_of_iterations)
        # when used with the group argument, scatter returns an array of traces
        traces_iris = scatter(data, group=:Species, x=xfeature, y=yfeature, mode="markers")
        traces_cluster = scatter(data, group=:Cluster, x=xfeature, y=yfeature, mode="markers")
        # layout with axis labels
        layout = PlotlyBase.Layout(
            xaxis=attr(title=String(xfeature)),
            yaxis=attr(title=String(yfeature),)
        )
        datatable = DataTable(data)
    end
end

@page("/", "app.jl.html")
